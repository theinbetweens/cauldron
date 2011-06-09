
class Push <InstanceCall
  
  def initialize
    
  end
  
  def write
    return '.push'
  end
  
  def copy
    return Push.new
  end
  
  def destructive?
    return true
  end
  
end