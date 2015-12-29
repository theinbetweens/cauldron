require 'rspec/expectations'

RSpec::Matchers.define :match_code_of do |expected|
  match do |actual|
    #actual % expected == 0
    Sorcerer.source(actual, indent: true).strip == Sorcerer.source(Ripper::SexpBuilder.new(expected).parse, indent: true).strip
  end
  failure_message_for_should do |actual|
    "expected that '#{Sorcerer.source(actual, indent: true).strip}' to be '#{Sorcerer.source(Ripper::SexpBuilder.new(expected).parse, indent: true).strip}'"
  end  
end