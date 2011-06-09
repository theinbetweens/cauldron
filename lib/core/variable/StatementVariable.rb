class StatementVariable < TypeVariable
  
  def initialize(val)
    super(val)
  end
  
  def copy
    copied = self.class.new(@value.copy) {{:variable_id => self.variable_id,:uniq_id=>@uniq_id, :uniq_id_history=>@uniq_id_history.copy}}
    copied.variable_id = self.variable_id
    return copied
  end  
  
  # Only let this method be called from fellow Fixnum classes or Unknowns
  def variable_id=(id)
    # TODO  This would be nicer if it wasn't so hard coded ./lib/core/variable/Unknown.rb
    unless caller.first.split(':')[0]==__FILE__ or caller.first.split(':')[0]=='./lib/core/statement/Statement.rb'
      raise StandardError.new('Illegal attempt to set variable_id')
    end
    @variable_id = id
  end     
  
  # Returns a copy of the variable, this method exists in the
  # instance call class.  It avoids distinguishing the two.  
  # Since variale is lowest level context doesn't matter.
  #
  def copy_contextual_variable
    return copy
  end    
  
  # Returns an array of instance calls the Statement instances can call.  Some
  # method calls require parameters.  These parameters are in the available
  # array.
  # 
  # @param  available     An array of variables to be included in the creation 
  #                       of the InstanceCallContainer.
  #
  def instance_calls(available=[])
    declared_variable_call = InstanceCallContainer.new(self.copy,DeclaredVariable.new)
    return [declared_variable_call]
  end
  
  # Returns an array of instances calls that return a value and are 
  # therefore approriate for declaration statements. 
  #
  def returning_instance_calls(available=[])
    return instance_calls(available)  
  end  
  
  #
  def destructive_instance_calls(available=[])
    return [] 
  end
  
  # Compares the passed argument and returns true if it is a unknown 
  # variable which is treated as a wild card or a variable with
  # the same value.  
  # 
  # TODO  I'm not sure I like UnkownVariables being treated as wild cards
  #
  def equivalent?(to)
    return true if to.kind_of?(Unknown)
    return false if to.class != self.class
    # TODO  I don't know if this is an equivalent comparision
    return false unless to.value.write == @value.write
    return true
  end      
  
#  def to_var
#    raise StandardError.new('Already a variable')
#  end
  
end