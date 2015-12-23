require 'rspec/expectations'

RSpec::Matchers.define :match_code_of do |expected|
  match do |actual|
    #actual % expected == 0
    Sorcerer.source(actual, indent: false).strip == Sorcerer.source(Ripper::SexpBuilder.new(expected).parse, indent: false)
  end
end