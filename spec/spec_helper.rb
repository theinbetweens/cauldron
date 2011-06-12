require 'cauldron'

# TODO  I would rather use the module:: Cauldron structure
require 'required'

def strip_whitespace(ruby_code)
  res = ruby_code.strip.gsub(/\t{1,}/,'\t').gsub(/\s{2,}/,'\n')
  return res.gsub('\t',"\t").gsub('\n',"\n")
end