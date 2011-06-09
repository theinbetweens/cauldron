class MethodParameterClass < ClassName
  
  def initialize
    super
  end
  
  def write(context=nil)
    return 'MethodParameter'
  end  
  
  def copy
    return MethodParameterClass.new
  end
  
  def value
    return MethodParameter
  end    
  
  # Returns an array of class methods call for the MethodUsage.  For example
  #
  # ClassMethodCallContainer.new(MethodUsageClass.new,New.new)
  #
  def class_method_calls(available=[])
    return [ClassMethodCallContainer.new(MethodParameterClass.new,New.new)]
  end  
  
end