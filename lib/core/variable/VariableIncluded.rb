# Classes that include this module are presumeed to include a variable,
# this is is used in the following classes.
#
# Variable
# InstanceCallContainer
# ArrayAccess
#
module VariableIncluded
  
  # Should have the following methods
  # variable
  
  # Returns the variable.  This call also exists in the InstanceCallContainer class.  It is
  # included to allow access of the variable with the need to disgiush whether it
  # is variable or an instance call.
  #
  def variable
    return self
  end    
  
  # Returns the actual variable with the specified id. 
  #
  def find_actual_variable(id)
    raise StandardError.new('Method needs defined in class')  
  end
  
end