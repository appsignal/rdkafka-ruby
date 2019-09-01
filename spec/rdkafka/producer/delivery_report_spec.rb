require "spec_helper"

describe Rdkafka::Producer::DeliveryReport do
  subject { Rdkafka::Producer::DeliveryReport.new(2, 100, "response") }

  it "should get the partition" do
    expect(subject.partition).to eq 2
  end

  it "should get the offset" do
    expect(subject.offset).to eq 100
  end

  it "should get the response" do
    expect(subject.response).to eq "response"
  end
end
