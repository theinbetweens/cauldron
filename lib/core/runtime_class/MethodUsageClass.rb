class MethodUsageClass < ClassName
  
  def initialize
    super
  end
  
  def write(context=nil)
    return 'MethodUsage'
  end  
  
  def copy
    return MethodUsageClass.new
  end
  
  def value
    return MethodUsage
  end
  
  # Returns an array of class methods call for the MethodUsage.  For example
  #
  # ClassMethodCallContainer.new(MethodUsageClass.new,New.new)
  #
  def class_method_calls(available=[])
    return [ClassMethodCallContainer.new(MethodUsageClass.new,New.new)]
  end
  
end