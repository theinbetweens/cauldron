class ThisClass < ClassName
  
  def initialize
    super
  end
  
  def write
    return 'This'
  end
  
  def copy
    return ThisClass.new
  end  
  
end