require 'rspec/expectations'

RSpec::Matchers.define :include_an_instance_of do |expected|
  match do |actual|
    #actual % expected == 0
    #Sorcerer.source(actual, indent: false).strip == Sorcerer.source(Ripper::SexpBuilder.new(expected).parse, indent: false)
    actual.any? { |x| x.kind_of?(expected) }
  end
end