
class ArrayVariable < TypeVariable
  attr_reader :variable_id  
  
  # TODO  Presumes that all parameters extends TypeVariable some are literals
  def initialize(*parameters)
    super(parameters)  
    parameters.each { |x| self.push(x) }
  end
  
  # TODO  Temporary overwrite - I'm not sure how to apply select_all for array variables.  
  #       When you write the variable it's var5 but it still contains addition variables.  
  def select_all(results=[],&block)
    #results.push(self) if block.call(self)
    return results
  end
  
    #TODO  Write tests for all variables to maintain uniq_id_history
  def copy
    result = ArrayVariable.new(*self.collect {|x| x.copy} ) {{:variable_id => self.variable_id,:uniq_id=>@uniq_id,:uniq_id_history=>@uniq_id_history.copy}}
    #result.variable_id = variable_id
    result.instance_variable = @instance_variable
    # TODO  I need to check uniq_id for 'copy' accross all the variables
    #result.uniq_id = @uniq_id
    return result
  end
  
  def to_declaration  
    return VariableDeclaration.new('ArrayVariable',*@value.collect {|x| x.to_declaration})
  end

  # Only let this method be called from fellow Fixnum classes or Unknowns
  def variable_id=(id)
    # TODO  This would be nicer if it wasn't so hard coded ./lib/core/variable/Unknown.rb
    unless caller.first.split(':')[0]==__FILE__ or caller.first.split(':')[0]=='./lib/core/variable/Unknown.rb'
      unless caller.first.split(':')[0]==__FILE__ or caller.first.split(':')[0]=='./lib/ruby_code/Array.rb'
        raise StandardError.new('Illegal attempt to set variable_id')
      end
    end
    @variable_id = id
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
    results = []    
    results.push InstanceCallContainer.new(self.copy,ArrayLength.new)

    # Attempt to create access calls - firstly with index
    self.length.times do |i|
        results.push ArrayAccess.new(self.copy,Literal.new(i))
    end

    return results
    
  end    
  
  def to_literal_string
    l = '['
    self.each do |x|
      l += x.to_literal_string
      unless x.object_id == self.last.object_id
        l += ','
      end
    end
    l += ']'
  end
      
end