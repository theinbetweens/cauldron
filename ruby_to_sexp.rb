require 'ripper'
require 'sorcerer'

sexp = Ripper::SexpBuilder.new("var0['foo']").parse
puts sexp.inspect
Sorcerer.source(sexp, indent: true)

