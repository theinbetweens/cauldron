class NilVariable < TypeVariable
  
  def initialize(id=nil)
    super(nil)
  end  
  
  def copy
    copied = NilVariable.new {{:variable_id => self.variable_id,:uniq_id=>@uniq_id, :uniq_id_history=>@uniq_id_history.copy}}
    #copied.variable_id = self.variable_id
    return copied
  end    
  
  # Only let this method be called from fellow NilVariable classes  
  def variable_id=(id)
    unless caller.first.split(':')[0]==__FILE__
      raise StandardError.new('Illegal attempt to set variable_id')
    end
    @variable_id = id
  end      
  
  def realised?
    return true
  end  
  
  def to_declaration
    return VariableDeclaration.new(self.class.to_s,nil.to_declaration)
  end
  
end