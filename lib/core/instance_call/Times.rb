
class Times < InstanceCall
  
  def initialize
    
  end
  
  def write
    return '.times'
  end
  
  def copy
    return Times.new
  end
  
  def destructive?
    return false
  end
  
end