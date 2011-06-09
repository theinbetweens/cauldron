class FixnumVariable < TypeVariable
  
  def initialize(val,id=nil)
    super(val,id)
  end
  
  # TODO  Write test
  def to_declaration
    return VariableDeclaration.new('FixnumVariable',@value.to_declaration)
  end  
  
  # TODO  I wan't to get rid of this call entirly
  def copy_contextual_variable
    return copy
  end    
  
  # Returns true if the variable type is Fixnum,  this is used 
  # to determine whether a BlockVariable or VariableContainer 
  # can be used as a particular variable type. 
  #
  def pass_as?(variable_type)
    return true if variable_type==FixnumVariable
    return false
  end
  
  # Returns an array of desctructive instance calls given the available
  # variables.
  # 
  # @param  available     An array of other variables that can be used as
  #                       parameters. 
  #
  def destructive_instance_calls(available=[])
    return []
  end  
  
end