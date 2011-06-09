class ArrayLength < InstanceCall
  
  def initialize
    super
  end
  
  def write
    return '.length'
  end
  
  def copy
    return ArrayLength.new
  end  
  
end