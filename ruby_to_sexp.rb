require 'ripper'
require 'sorcerer'

sexp = Ripper::SexpBuilder.new('var0 + 5').parse

Sorcerer.source(sexp, indent: true)