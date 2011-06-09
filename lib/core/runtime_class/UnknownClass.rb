class UnknownClass < ClassName
  
  def initialize
    super 
  end

  def write(context=nil)
    return 'Unknown'
  end  
  
  def copy
    return UnknownClass.new
  end

  def value
    return Unknown
  end

  def declaration_statement
    return ClassMethodCallContainer.new(Unknown.new,New.new)
  end
  
end