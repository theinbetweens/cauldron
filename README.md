[![Code Climate](https://codeclimate.com/github/theinbetweens/cauldron/badges/gpa.svg)](https://codeclimate.com/github/theinbetweens/cauldron)

[![Build Status](https://semaphoreci.com/api/v1/projects/68fafc64-3ef2-41f6-8936-d69d40e0fe2b/617362/badge.svg)](https://semaphoreci.com/theinbetweens/cauldron)

## Usage

**Cauldron** can generate a very limited range of simple ruby functions to solve supplied problem. The following example will print the following ruby code.

```ruby
def function(var0)
  var0 + 1
end
```

```ruby
require 'cauldron'

pot = Cauldron::Pot.new
result = pot.solve(
  [
    {arguments: [7], response: 8},
    {arguments: [10], response: 11}
  ]
)
puts result
```