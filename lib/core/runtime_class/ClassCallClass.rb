class ClassCallClass < ClassName
  
  def initialize
    super 
  end

  def write(context=nil)
    return 'ClassCall'
  end
  
  def copy
    return ClassCallClass.new
  end

  def value
    return ClassCall
  end

#  def declaration_statement
#    return ClassMethodCallContainer.new(ClassCall.new,New.new)
#  end

end