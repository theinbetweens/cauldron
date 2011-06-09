# Instances of this class describe the parameters that a method uses
# and is required to have
#
class MethodUsage < Array
  
  def initialize(*parameters)
    super()
    
    # Check the data type of the provided variables
    parameters.each do |x|
      unless x.kind_of? MethodParameter then raise StandardError.new('Unexpected data type: '+x.class.to_s+' expecting MethodParameter') end
    end
    
    # Add the method variables to your self
    parameters.collect {|param| self.push param}
    
  end
  
  # Check whether the rule matches the usage of the method.  Essentially
  # checking that the number of parameters is correct and the data types
  # are acceptable.
  #
  def valid_rule? rule
    
    # Check that correct number of parameters are provided
    unless rule.paramater_count == self.length then raise ParameterCountError.new('Expected '+self.length.to_s+' parameters') end
    
  end
  
  def write
    line = 'MethodUsage.new('    
    self.each do |x|
      line += x.to_declaration.write
      unless x.object_id == self.last.object_id then line += ', ' end
    end
    line += ')'
    return line        
  end
  
  # Returns this method usage case as MethodUsageVariable instance.
  # 
  # TODO  I'm not sure I should be allow this to set it's id
  #
  def to_var(id=nil,uniq_id=nil)
    if id.nil? then return MethodUsageVariable.new(*self.collect {|x| x.copy}) end         
    return MethodUsageVariable.new(*self.collect {|x| x.copy}) {{:variable_id => id,:uniq_id=>uniq_id}}
  end
  
  # TODO  Test this 
  def copy
    return MethodUsage.new(*self.collect {|x| x.copy})
  end
  
  def to_declaration
    return VariableDeclaration.new('MethodUsage',*self.collect {|x| x.to_declaration})
  end
  
end

class ParameterCountError < StandardError
  
  def initialize(msg)
    super(msg)
  end
  
end