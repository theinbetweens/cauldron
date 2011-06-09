# TODO  Change this to InstanceClassCall = remember it needs to be changed to InstanceClassCallClass
#
# TODO  Move this to instance_call
#
# This represents the .class element of statements like
# e.g. var_a.class
#
class ClassCall <InstanceCall

	def initialize
   super 
	end

  def write
    return '.class'
  end
  
  def copy
    return ClassCall.new
  end

  # The class call has no requirements since every object has
  # this methods.
  #
  def requirements
    return []
  end

  def declaration_statement
    return ClassMethodCallContainer.new(ClassCallClass.new,New.new)
  end

end