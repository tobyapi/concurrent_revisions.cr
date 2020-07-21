# concurrent_revisions

[Concurrent Revisions](https://www.microsoft.com/en-us/research/project/concurrent-revisions/) is a concurrency control model designed to guarantee determinacy, meaning that each forked task gets a conceptual copy of all the shared state, and state changes are integrated only when tasks are joined, at which time write-write conflicts are deterministically resolved.

## Installation

Clone repository manually:

```sh
git clone https://github.com/TobiasGSmollett/concurrent_rivisions.cr && cd concurrent_revisions.cr/
```

Or add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     concurrent_revisions:
       github: TobiasGSmollett/concurrent_revisions.cr
   ```

Run `shards install`.

## Usage

The fastest way to try it is by using Crystal Playground (crystal play):

```crystal
require "concurrent_revisions"

include ConcurrentRevisions

x = Versioned(Int32).new(0)
y = Versioned(Int32).new(0)

r : Revision = rfork do
  x.set(1)
  rfork { }
  x.set(y.get)
end

x.set(2)
rjoin(r)

puts "#{x.get} #{y.get}" # => 0 0
```

## References
- [Concurrent Programming with Revisions and Isolation Types](https://www.microsoft.com/en-us/research/publication/concurrent-programming-with-revisions-and-isolation-types/)

## Contributing

1. Fork it (<https://github.com/TobiasGSmollett/concurrent_revisions/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [tobya](https://github.com/TobiasGSmollett) - creator and maintainer
