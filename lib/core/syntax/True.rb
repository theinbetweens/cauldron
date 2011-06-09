
class True < Boolean
  
  def initialize
    
  end
  
  def write
    return 'true'
  end
  
  def describe
    return write
  end
  
  def copy
    return True.new
  end
  
end