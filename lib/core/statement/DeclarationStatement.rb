# This class represents statements that declare new variables.
# e.g.    var = 'test'.chop
#         var1 = var2.pop
# 
class DeclarationStatement < Statement
  
  def initialize(*parameters)
    super(*parameters)
  end
  
  # Returns the declared variable.  So in he case where
  # there is var = 8 it would return var.  This is always
  # the first entry.
  #
  def declared
    return self.first
  end
  
end