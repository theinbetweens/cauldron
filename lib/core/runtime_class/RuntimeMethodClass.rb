class RuntimeMethodClass < ClassName
  
  def initialize
    super
  end
  
  def write(context=nil)
    return 'RuntimeMethod'
  end  
  
  def copy
    return RuntimeMethodClass.new
  end
  
  def value
    return RuntimeMethod
  end
  
  # TODO  I'm not sure if this is needed
  def declaration_statement
    return ClassMethodCallContainer.new(RuntimeMethodClass.new,New.new)
  end
  
  # Returns an array of class methods call for the RuntimeMethod.  For example
  #
  # ClassMethodCallContainer.new(RuntimeMethodClass.new,New.new,x)
  #   - where x is a MethodUsage instance
  #
  def class_method_calls(available=[])
    method_usage_variables = available.select {|x| x.kind_of?(MethodUsageVariable)}
    return method_usage_variables.collect {|x| ClassMethodCallContainer.new(RuntimeMethodClass.new,New.new,x)}
  end  
  
end