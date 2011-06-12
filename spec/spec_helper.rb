require 'cauldron'

# TODO  I would rather use the module:: Cauldron structure
require 'required'

def strip_whitespace(ruby_code)
  ruby_code.strip.gsub(/\s{2,}/,"\n")
end