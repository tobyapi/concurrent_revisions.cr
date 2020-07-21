require "./spec_helper"

include ConcurrentRevisions

describe Segment do
  it "creates a segment" do
    Segment.version_count = 1
    s = Segment.new
  
    s.parent.should eq nil
    s.version.should eq 1
    s.refcount.should eq 1
  end

  it "creates two segments" do
    s1 = Segment.new
    s2 = Segment.new(s1)

    s1.parent.should eq nil
    s2.parent.should eq s1
    s1.version.should eq 1
    s2.version.should eq 2
    s1.refcount.should eq 2
    s2.refcount.should eq 1
  end

  it "releases a segment" do
    Segment.version_count = 1
    s = Segment.new
    s.release

    s.parent.should eq nil
    s.version.should eq 1
    s.refcount.should eq 0
  end
end