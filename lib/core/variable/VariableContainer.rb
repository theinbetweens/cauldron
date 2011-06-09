class VariableContainer < BaseVariable
  
  attr_writer :realised
  
  def initialize
    super()
    
    @realised = false
  end  
  
  # Returns a duplicate of this variable container.  
  # 
  def copy
    result = VariableContainer.new(){{:variable_id => self.variable_id,:uniq_id=>@uniq_id, :uniq_id_history=>@uniq_id_history.copy}}
    result.instance_variable = @instance_variable    
    self.each do |x|
      result.push(x)
    end
    result.realised = @realised
    return result        
  end
  
  # TODO  Write description - hack for instance calls
  def variable
    return self
  end
  
end