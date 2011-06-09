#
# This module is used in the various code containers used in Cauldren
#
module ActsAsCode
  
  # Returns a string description of the statement with any of tokens replaced with 
  # token markers.
  # 
  # So var_1 = var_2 + 3
  #
  # becomes a = b + c
  #
  # The order of replacement is important, the first token becomes a, the second b
  # and so forth.
  # 
  def write_structure
      # TODO  Not sure how to handle duplicate literals
      output = self.write
      self.tokens.zip(('a'..'z').to_a) do |x,y|
        output.gsub!(x.write,y)
      end      
      return output
  end   
   
end