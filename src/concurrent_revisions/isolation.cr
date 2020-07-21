require "./revision"
require "./segment"

module ConcurrentRevisions
  module Isolation
    abstract def release(release : Segment)
    abstract def collapse(main : Revision, parent : Segment)
    abstract def merge(main : Revision, join_rev : Revision, join : Segment)
  end
end