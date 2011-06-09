class RuntimeClassMethodCall
  
  def initialize()
    
  end
  
  def copy
    raise StandardError.new('Copy hasn\'nt been included for ('+self.class.to_s+')')
  end
  
  def requirements
    raise StandardError.new('Requirements have not been defined for '+self.class.to_s+'')
  end
  
  def write
    raise StandardError.new('"write" has not been defined for '+self.class.to_s+'')
  end
  
  def use(*parameters)
    raise StandardError.new('"use" has not been defined for '+self.class.to_s+'')
  end  
  
  def to_literal_string
    return self.write
  end
  
  def closure
    return ['(',')']
  end  
  
end