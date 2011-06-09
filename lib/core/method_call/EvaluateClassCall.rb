# NOTE: This class call shouldn't be made available during runtime method
#       generation. - it would just get messy.
#
class EvaluateClassCall < InstanceCall
  
  def initialize
   super 
  end

  def write
    return '.evaluate_class'
  end
  
  def copy
    return EvaluateClassCall.new
  end

  # The class call has no requirements since every object has
  # this methods.
  #
  def requirements
    return []
  end

  def declaration_statement
    return ClassMethodCallContainer.new(EvaluateClassCall.new,New.new)
  end  
  
end