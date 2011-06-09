# This class is used to include code into a statement without having 
# to create the correct classes etc.
#
# It is currently only used for method validation, where I want a quick
# check that a generated method is correct e.g. 
#
# ' == "Test"'
# 
class Raw
  
  def initialize(value)
    @value = value
  end
  
  def write()
    return @value
  end
  
  def copy
    return Raw.new(@value.copy)
  end
  
end