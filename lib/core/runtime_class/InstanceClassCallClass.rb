class InstanceClassCallClass < ClassName
  
  def initialize
    super
  end
  
  def write(context=nil)
    return 'ClassCall'
  end
  
  def copy
    return InstanceClassCallClass.new
  end

  def value
    return ClassCall
  end  
  
end