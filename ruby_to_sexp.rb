require 'ripper'
require 'sorcerer'

sexp = Ripper::SexpBuilder.new("var0['foo']").parse
puts sexp.inspect
Sorcerer.source(sexp, indent: true)


sexp = Ripper::SexpBuilder.new(%q{
  var0.collect do |x|
    record(local_variable)
  end
}).parse
puts sexp.inspect
Sorcerer.source(sexp, indent: true)