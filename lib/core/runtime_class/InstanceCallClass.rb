class InstanceCallClass < ClassName
  
  def initialize
    super 
  end

  def write(context=nil)
    return 'InstanceCall'
  end
  
  def copy
    return InstanceCallClass.new
  end

  def value
    return InstanceCall
  end

end