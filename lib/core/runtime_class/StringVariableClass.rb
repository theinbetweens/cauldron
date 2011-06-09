class StringVariableClass < ClassName
  
  def initialize
    super
  end
  
  def write(context=nil)
    return 'StringVariable'
  end  
  
  def copy
    return StringVariableClass.new
  end
  
  def value
    return StringVariable
  end      
  
end