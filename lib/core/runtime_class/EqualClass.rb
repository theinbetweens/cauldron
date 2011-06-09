class EqualClass < ClassName
  
  def initialize
    super 
  end

  def write(context=nil)
    return 'Equal'
  end
  
  def copy
    return EqualClass.new
  end

  def value
    return Equal
  end

end