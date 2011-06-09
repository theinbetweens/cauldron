# I'm not sure whether to keep this class as I already have BlockVariable but that
# is a bit overkill - I'm not sure I need to keep BlockVariable either.
#
# Instances of this are used in theories where a variable that shouldn't be 
# replaced is used.  This might be a Global variable or a block variable.
#
# if(var1.any? {|x| x == var2})
#   return false 
# end
# 
# In the theory above if x was a normal TheoryVariable it would be replaced and the theory 
# would break.
#
class BlockToken 
  include Token
  
  def initialize(identitiy)
    @identitiy = identitiy  
  end
  
  def write
    return @identitiy
  end
  
  def describe
    return write
  end
  
  def copy
    return BlockToken.new(@identitiy.copy)
  end
  
end