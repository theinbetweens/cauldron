
class MethodNameCall < InstanceCall

  def initialize
   super 
  end

  def write
    return '.method_name'
  end
  
  def copy
    return MethodNameCall.new
  end

  # The class call has no requirements since every object has
  # this methods.
  #
  def requirements
    return []
  end

  def declaration_statement
    return ClassMethodCallContainer.new(MethodNameCall.new,New.new)
  end

end