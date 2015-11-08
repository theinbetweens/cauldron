require 'ripper'
require 'sorcerer'
require 'pp'

sexp = Ripper::SexpBuilder.new("x.concat('bar')").parse
pp sexp
pp Sorcerer.source(sexp, indent: true)
puts '===='


sexp = Ripper::SexpBuilder.new(%q{
var1 = var0.collect do |x|
  x
end
}).parse
puts sexp.inspect

puts '-------'

sexp = Ripper::SexpBuilder.new(%q{
  var0.collect do |x|
    record(local_variable)
  end
}).parse
puts sexp.inspect
Sorcerer.source(sexp, indent: true)