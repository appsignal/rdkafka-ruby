require "spec_helper"

describe Rdkafka::Bindings do
  it "should load librdkafka" do
    expect(Rdkafka::Bindings.ffi_libraries.map(&:name).first).to include "librdkafka"
  end

  describe ".lib_extension" do
    it "should know the lib extension for darwin" do
      stub_const('RbConfig::CONFIG', 'host_os' =>'darwin')
      expect(Rdkafka::Bindings.lib_extension).to eq "dylib"
    end

    it "should know the lib extension for linux" do
      stub_const('RbConfig::CONFIG', 'host_os' =>'linux')
      expect(Rdkafka::Bindings.lib_extension).to eq "so"
    end
  end

  it "should successfully call librdkafka" do
    expect {
      Rdkafka::Bindings.rd_kafka_conf_new
    }.not_to raise_error
  end

  describe "log callback" do
    let(:log) { StringIO.new }
    before do
      Rdkafka::Config.logger = Logger.new(log)
    end

    it "should log fatal messages" do
      Rdkafka::Bindings::LogCallback.call(nil, 0, nil, "log line")
      expect(log.string).to include "FATAL -- : rdkafka: log line"
    end

    it "should log error messages" do
      Rdkafka::Bindings::LogCallback.call(nil, 3, nil, "log line")
      expect(log.string).to include "ERROR -- : rdkafka: log line"
    end

    it "should log warning messages" do
      Rdkafka::Bindings::LogCallback.call(nil, 4, nil, "log line")
      expect(log.string).to include "WARN -- : rdkafka: log line"
    end

    it "should log info messages" do
      Rdkafka::Bindings::LogCallback.call(nil, 5, nil, "log line")
      expect(log.string).to include "INFO -- : rdkafka: log line"
    end

    it "should log debug messages" do
      Rdkafka::Bindings::LogCallback.call(nil, 7, nil, "log line")
      expect(log.string).to include "DEBUG -- : rdkafka: log line"
    end

    it "should log unknown messages" do
      Rdkafka::Bindings::LogCallback.call(nil, 100, nil, "log line")
      expect(log.string).to include "ANY -- : rdkafka: log line"
    end
  end

  describe "stats callback" do
    context "without a stats callback" do
      it "should do nothing" do
        expect {
          Rdkafka::Bindings::StatsCallback.call(nil, "{}", 2, nil)
        }.not_to raise_error
      end
    end

    context "with a stats callback" do
      before do
        Rdkafka::Config.statistics_callback = lambda do |stats|
          $received_stats = stats
        end
      end

      it "should call the stats callback with a stats hash" do
        Rdkafka::Bindings::StatsCallback.call(nil, "{\"received\":1}", 13, nil)
        expect($received_stats).to eq({'received' => 1})
      end
    end
  end
end
