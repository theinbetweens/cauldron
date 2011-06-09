class StringVariable < TypeVariable
  
  def initialize(val,id=nil)
    super(val,id)
  end  
  
  # Returns an array of instance calls for the particular type
  # variable.  For example:
  #
  # StringVariable.new('test').instance_calls
  #
  # might return [var.chop,var.length]
  #
  def instance_calls(available=[])
    
    # Add the chop instance call
    chop_call = InstanceCallContainer.new(self.copy,Chop.new)
    length_call = InstanceCallContainer.new(self.copy,StringLength.new)
    return [chop_call,length_call]
    
  end  
  
  def to_declaration
    return VariableDeclaration.new(self.class.to_s,@value.to_declaration)
  end
  
  def to_literal_string
    return @value.to_literal_string
  end
  
  # TODO  I wan't to get rid of this call entirly
  def copy_contextual_variable
    return copy
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