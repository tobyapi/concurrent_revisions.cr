require "./cumulative"
require "./isolation"

module ConcurrentRevisions
  class Segment
    getter parent : Segment?
    getter version : Int32
    getter written : Array(Isolation)

    property refcount : Int32

    @@version_count = 0

    # for test
    # :nodoc:
    def self.version_count=(value : Int32)
      @@version_count = value
    end

    def initialize(@parent = nil)
      @parent.as(Segment).refcount += 1 if !@parent.nil?
      @written = [] of Isolation
      @version = @@version_count
      @@version_count += 1
      @refcount = 1
    end

    def release
      @refcount -= 1
      if @refcount == 0
        @written.each { |v| v.release(self) }
        @parent.as(Segment).release if !@parent.nil?
      end
    end

    def collapse(main : Revision)
      # assert : main.current = self
      while @parent != main.root && @parent.as(Segment).refcount == 1
        @parent.as(Segment).written.each { |v| v.collapse(main, @parent.as(Segment)) }
        # remove parent
        @parent = @parent.as(Segment).parent
      end
    end
  end
end
