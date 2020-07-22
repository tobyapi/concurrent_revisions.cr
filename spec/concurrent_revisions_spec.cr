require "./spec_helper"

include ConcurrentRevisions

describe ConcurrentRevisions do
  it "Example" do  
    x = Versioned(Int32).new(0)
    y = Versioned(Int32).new(0)
  
    r : Revision = rfork do
      x.set(1)
  
      Revision.current_revision.current.version.should eq 2
  
      rfork { }
      x.set(y.get)
  
      Revision.current_revision.current.version.should eq 3
    end
    Revision.current_revision.current.version.should eq 1
  
    x.set(2)
    rjoin(r)
  
    x.get.should eq 0
    y.get.should eq 0
  end

  it "Example 2" do
    x = Cumulative(Int32).new(0) do |original, master, revised|
      master + revised - original
    end

    r2 = nil

    r1 = rfork do
      x.set(x.get + 1)
      r2 = rfork do
        x.set(x.get + 3)
      end
    end
    x.set(x.get + 2)
    rjoin(r1)
    x.set(x.get + 4)
    rjoin(r2.as(Revision))

    x.get.should eq 10
  end
end
