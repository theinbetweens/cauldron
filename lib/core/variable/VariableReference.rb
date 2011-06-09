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
class VariableReference
  include Variable  
  
  attr_reader :variable_id
  
  # 
  # @param  referenced_variable_id      
  #
  def initialize(var_id,referenced_variable_id)
    @variable_id = var_id
    @referenced_variable_id = referenced_variable_id
    raise StandardError.new('I am getting rid of this')
  end
  
  def copy
    return VariableReference.new(@variable_id,@referenced_variable_id)
  end
  
  # Returns the variable if the ids matched
  #
  # @param  id    The id of the variable that is being looked for
  #
  def find_actual_variable(id)
    return self if @variable_id == id
    throw :variable_not_found
  end  
  
  #
  # 
  #
  def write()
    if (@instance_variable)
      return '@var_'+variable_id.to_s    
    end
    return 'var_'+variable_id.to_s    
  end   
  
  def to_literal_string
    return 'var'  
  end  
  
  def realised?
    return false
  end  
  
  # TODO  Write tests for this
  # Returns an array of desctructive instance calls given the available
  # variables.
  # 
  # @param  available     An array of other variables that can be used as
  #                       parameters. 
  #
  def destructive_instance_calls(available=[])
    
    # Find the variable it references
    available_variables = available.select {|x| x.kind_of?(Variable)}

    not_found = lambda{raise StandardError.new('Unable to find variable with id '+@referenced_variable_id.to_s)}
    referenced_variable = available_variables.detect(not_found) {|x| x.variable_id == @referenced_variable_id}
      
    # Duplicate the referenced variable and update it's variable id
    duplicated_var = referenced_variable.copy
    duplicated_var.variable_id = @variable_id
    
    return duplicated_var.destructive_instance_calls(available)
    
  end    
  
end