# TODO Really want a nice indent solution - like cucumber
# http://stackoverflow.com/questions/3350648/ruby-indented-multiline-strings
# Personally, I think that Ruby's indented heredocs are useless and they should work more like Bash indented heredocs and also strip whitespace inside the string …

# Anyway, there are a couple of libraries that try to deal with this situation. There is a wide array of libraries that try to fix this problem:

#     Martin Aumont's Unindent library which is also part of the Facets library
#     Facets also provides String#margin
#     Sunlight Labs' Unindentable library
#     Samuel Dana's Indentation library

# https://github.com/Mynyml/Unindent/
class String
  def unindent
    indent = self.split("\n").select {|line| !line.strip.empty? }.map {|line| line.index(/[^\s]/) }.compact.min || 0
    self.gsub(/^[[:blank:]]{#{indent}}/, '')
  end
  def unindent!
    self.replace(self.unindent)
  end
end