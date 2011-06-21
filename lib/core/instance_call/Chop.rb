class Chop <InstanceCall
  
  def initialize
    super
  end
  
  def write
    return '.chop'
  end
  
  def copy
    return Chop.new
  end
  
  def use(val)
    return val.chop
  end
  
end