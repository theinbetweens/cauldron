# This a generic structure that can be used to create any number of 
# instance method calls.  For example if it was meant to represent 
# an array instance it might be able to produce the statement:
# 
# array.push(some_value)
# 
# TODO  This might duplicate the functionality of the InstanceCallContainerStructure 
#       although I can't remember what I created that for.
# 
class InstanceMethodCallStructure < StatementStructure
  
  # 
  # @param  instance_class    The class of the instance that has a method call
  # @param  method_call       A method call instance that can be called from 
  #                           instances of the supplied instance_class.
  # 
  def initialize(instance_class,method_call)

  end
  
end