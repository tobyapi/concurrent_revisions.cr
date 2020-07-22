require "./isolation"
require "./revision"
require "./segment"

module ConcurrentRevisions
  class Cumulative(T)
    include Isolation
    
    # map from version to value
    @versions : Hash(Int32, T)

    # argumetns of @merge_func are (original, master, reviesd)
    def initialize(value : T, &@merge_func : T, T, T -> T)
      @versions = {} of Int32 => T
      set(value)
    end

    def get
      get(Revision.current_revision)
    end

    def set(value : T)
      set(Revision.current_revision, value)
    end

    def get(r : Revision) : T
      s : Segment = r.current
      until @versions.has_key?(s.version)
        s = s.parent.as(Segment)
      end
      @versions[s.version]
    end

    def set(r : Revision, value : T)
      unless @versions.has_key?(r.current.version)
        r.current.written.push(self) 
      end
      @versions[r.current.version] = value
    end

    def release(release : Segment)
      @versions.delete(release.version)
    end

    def collapse(main : Revision, parent : Segment)
      unless @versions.has_key?(main.current.version)
        set(main, @versions[parent.version])
      end
      @versions.delete(parent.version)
    end

    def merge(main : Revision, join_rev : Revision, join : Segment)
      s : Segment = join_rev.current
      until @versions.has_key?(s.version)
        s = s.parent.as(Segment)
      end
      revised = @versions[join.version]
      master = @versions[main.current.version]
      original = @versions[join_rev.root.version]
      merged_value = @merge_func.call(original, master, revised)
      # only merge if this was the last write
      set(main, merged_value) if s == join
    end
  end
end
