require "./segment"

module ConcurrentRevisions
  # :nodoc:
  class Task
    @channel = Channel(Nil).new

    def initialize(&@block)
    end

    def run
      spawn do
        @block.call
        @channel.send(nil)
      end
    end

    def wait
      @channel.receive
    end
  end

  class Revision
    getter root : Segment
    getter current : Segment

    property task : Task?

    @[ThreadLocal]
    @@current_revision : Revision = Revision.new((root_segment = Segment.new), root_segment)

    def self.current_revision
      @@current_revision
    end

    def initialize(@root : Segment, @current : Segment)
    end

    def fork(&action)
      seg = Segment.new(@current)
      r = Revision.new(@current, Segment.new(@current))
      # cannot bring refcount to zero
      @current.release
      @current = seg

      r.task = Task.new {
        previous = @@current_revision
        @@current_revision = r
        begin
          action.call
        ensure
          @@current_revision = previous
        end
      }
      r.task.as(Task).run
      r
    end

    def join(join : Revision)
      begin
        join.@task.as(Task).wait
        s : Segment = join.current
        while s != join.root
          s.written.each { |v| v.merge(self, join, s) }
          s = s.parent.as(Segment)
        end
      ensure
        join.current.release
        @current.collapse(self)
      end
    end
  end
end
