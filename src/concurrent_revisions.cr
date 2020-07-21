require "./concurrent_revisions/cumulative"
require "./concurrent_revisions/revision"
require "./concurrent_revisions/segment"
require "./concurrent_revisions/versioned"

module ConcurrentRevisions
  VERSION = "0.1.0"
end

def rfork(&block)
  Revision.current_revision.fork &block
end

def rjoin(r : Revision)
  Revision.current_revision.join(r)
end