class Subtract  < InstanceCall
  
  def initialize
    
  end
  
  def copy
    return self.class.new
  end
  
  def write
    return ' -'
  end
  
  def closure
    return [' ','']
  end     
  
end