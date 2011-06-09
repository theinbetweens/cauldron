class MethodUsageVariable < BaseVariable
  
  def initialize(*parameters)
    super()
    raise StandardError.new('Only submit the paramaters on the usage variable') if parameters.first.kind_of?(MethodUsage)
    # Go through each paramater in the method usage instance
    parameters.each do |x|
      self.push x.copy
    end
    
  end
  
  def to_declaration
    return VariableDeclaration.new('MethodUsageVariable',*self.collect {|x| x.to_declaration})
  end
  
  def copy
    result = MethodUsageVariable.new(*self.collect {|x| x.copy}) {{:variable_id => self.variable_id,:uniq_id=>@uniq_id, :uniq_id_history=>@uniq_id_history.copy}}
    return result
  end
  
#  # Only let this method be called from fellow Fixnum classes or Unknowns
#  def variable_id=(id)
#    # TODO  This would be nicer if it wasn't so hard coded ./lib/core/variable/Unknown.rb
#    unless caller.first.split(':')[0]==__FILE__ or caller.first.split(':')[0]=='./lib/core/variable/Unknown.rb'
#      raise StandardError.new('Illegal attempt to set variable_id')
#    end
#    @variable_id = id
#  end
  
  # TODO  Test this
  def to_literal_string
    l = 'MethodUsage.new('
    self.each do |x|
      l += x.to_literal_string
      unless x.object_id == self.last.object_id
        l += ','
      end
    end
    l += ')'    
    return l
  end      
  
  # TODO  Write tests
  # Compares the passed argument and returns true if they are 
  # the same class and contains the same values.
  #
  def equivalent?(to)
    return false if to.class != self.class
    to.zip(self) do |x,y|
      return false unless x.equivalent?(y)
    end
    return true
  end   
  
  def destructive_instance_calls(with=[])
    return []  
  end
  
end