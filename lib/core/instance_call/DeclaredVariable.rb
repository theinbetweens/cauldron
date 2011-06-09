class DeclaredVariable <InstanceCall
  
  def initialize    
  end
  
  def write
    return '.declared_variable'
  end
  
  def copy
    return DeclaredVariable.new
  end
  
  def destructive?
    return false
  end
  
end