require 'ripper'
require 'sorcerer'
require 'pp'

sexp = Ripper::SexpBuilder.new(%q{
var0.to_s
}).parse
pp sexp
pp Sorcerer.source(sexp, indent: true)
puts '===='

sexp = Ripper::SexpBuilder.new(%q{
def test(var0)
  var0.bounce
  var1.kick
end
}).parse
pp sexp
pp Sorcerer.source(sexp, indent: true)
puts '===='


sexp = Ripper::SexpBuilder.new(%q{
var1 = var0.collect do |x|
  x + 2
end
var2 = var1.collect do |x|
  x.to_s
end
}).parse
puts sexp.inspect
pp sexp
puts '-------'

sexp = Ripper::SexpBuilder.new(%q{
var0.collect do |x|
  record(local_variable)
end
}).parse
puts sexp.inspect
pp sexp
Sorcerer.source(sexp, indent: true)

puts '================'
sexp = Ripper::SexpBuilder.new(%q{
var0.collect do |var1|
  record(0)
end
record(1)
}).parse
puts sexp.inspect
pp sexp
Sorcerer.source(sexp, indent: true)

puts '================'
sexp = Ripper::SexpBuilder.new(%q{
var0.collect do |var1|
  var1 * 3 
end
}).parse
pp sexp
Sorcerer.source(sexp, indent: true)

puts '================'
sexp = Ripper::SexpBuilder.new(%q{
def function(var0)
  var0.collect do |var1|
    record(0,1,1,local_variables.reject {|foo| foo == :_}.collect { |bar| [bar, eval(bar.to_s)] })
  end
  record(1,0,1,local_variables.reject {|foo| foo == :_}.collect { |bar| [bar, eval(bar.to_s)] })
end
}).parse
pp sexp
Sorcerer.source(sexp, indent: true)
