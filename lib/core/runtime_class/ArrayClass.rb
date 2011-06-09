class ArrayClass < ClassName
  
  def initialize
    super 
  end

  def write(context=nil)
    return 'Array'
  end
  
  def copy
    return ArrayClass.new
  end

  def value
    return FixnumClass
  end  
  
end