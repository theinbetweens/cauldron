require 'rspec/expectations'

RSpec::Matchers.define :match_code_of do |expected|
  match do |actual|
    #actual % expected == 0
    Sorcerer.source(actual, indent: true).strip == expected.strip
  end
end