class RuntimeClassClass < ClassName
  
  def initialize
    super 
  end

  def write(context=nil)
    return 'RuntimeClass'
  end
  
  def copy
    return RuntimeClassClass.new
  end

  def value
    return RuntimeClass
  end  
  
end