require "./spec_helper"

include ConcurrentRevisions

describe Versioned do
  it "get" do
    x = Versioned(Int32).new(1000)

    expected_versions = {0 => 1000}

    x.get.should eq 1000
    x.@versions.should eq expected_versions
  end

  it "set" do
    x = Versioned(Int32).new(1000)
    x.set(100)

    x.get.should eq 100
    x.@versions.should eq ({0 => 100})
  end
end