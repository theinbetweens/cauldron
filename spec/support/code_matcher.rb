require 'rspec/expectations'

RSpec::Matchers.define :match_code_of do |expected|
  match do |actual|
    #actual % expected == 0
    Sorcerer.source(actual, indent: false).strip == Sorcerer.source(Ripper::SexpBuilder.new(expected).parse, indent: false)
  end
  failure_message_for_should do |actual|
    "expected that '#{Sorcerer.source(actual, indent: false).strip}' to match '#{Sorcerer.source(Ripper::SexpBuilder.new(expected).parse, indent: false)}'"
  end  
end