
class InstanceCall < Array
  
  def initialize(*parameters)
    super()
    parameters.each do |param|
      self.push(param)
    end
  end
  
  def copy
    return self.class.new
  end
  
  def requirements
    raise StandardError.new('Requirements have not been defined for '+self.class.to_s+'')
  end
  
  def write
    raise StandardError.new('"write" has not been defined for '+self.class.to_s+'')
  end

  def to_literal_string
    return write
  end  
  
  def use(*parameters)
    raise StandardError.new('"use" has not been defined for '+self.class.to_s+'')
  end
  
  def response
    raise StandardError.new('"response" has not been defined for '+self.class.to_s+'')
  end
  
  # Returns true or false depending on whether the method call is 
  # destructive or not.  Destructive calls would be chop! or
  # .push(x) since they change the value of the subject.
  #
  def destructive?
    raise StandardError.new('"destructive?" has not been defined for '+self.class.to_s+'')
  end
  
  # Returns a more detailed explaination than 'write' of the method call.
  def describe
    return write
  end
  
  def to_literal_string
    return write
  end
  
  def to_declaration
    return VariableDeclaration.new(self.class.to_s)
  end
  
  def closure
    return ['(',')']
  end    
  
  # Returns true if the method call can safely used with the 
  # literal provided.  Otherwise it returns false.
  #
  def valid_syntax?(literal)
      
    # Check that a literal has been passed through
    raise StandardError.new('Only a literal value can be directly evaluated') unless literal.kind_of?(Literal) 
    
    # Create the statement that uses the code
    statement = literal.write+'.'+self.write

    # Use the test and check for syntax error
    return true if(StatementCheck.new.valid_syntax?(statement))
    return false
    
  end
  
end