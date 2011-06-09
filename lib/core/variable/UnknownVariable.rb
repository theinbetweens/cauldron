# NOTE FROM VARIABLE REFERENCE
# I'm not sure if this is the way to go, but I need some way
# to handle the case where variables reference variables. 
#
# For example:
#
#  #
#  #
#  def method_8
#    var_12 = Statement.new(Unknown.new,Equal.new,8.to_declaration) 
#    var_570 = var_12.declared_variable 
#  end
#
# In this case it is difficult to realise var_570 since it references an 
# unrealised variable.  I should maybe have created an Unknown class, but
# it is still an Unknown.
# 
class UnknownVariable < TypeVariable
  
  def initialize(val,id=nil)
    super(val,id)
  end
  
  #
  def destructive_instance_calls(available=[])
    return [] 
  end  
  
end