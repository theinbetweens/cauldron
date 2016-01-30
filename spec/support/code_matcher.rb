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

RSpec::Matchers.define :match_history do |expected|

  lines = expected.split("\n").reject {|x| x.match(/^\s*$/) }
  lines = lines.collect(&:strip)
  lines = lines.collect { |line| line.gsub(/\|/,'') }
  
  lines = lines.collect do |line|
    eval(
      Sorcerer.source(
        Ripper::SexpBuilder.new(line).parse
      )
    )
  end
  match do |actual|
    index = -1
    actual.all? do |x|
      index += 1
      x == lines[index]
    end
    # next false unless actual.length == lines.length
    # actual.each_with_index do |value,index|
    #   next false unless actual[index] == lines[index]
    # end
    # true
  end

  failure_message_for_should do |actual|
    %Q{expected '#{expected}' == #{actual.inspect}}
  end
  #res = eval(Sorcerer.source(Ripper::SexpBuilder.new(%q{{line: 0, depth: 1, var0: ['lion', 'bear'], var1: 'lion'}}).parse))
  #binding.pry
end