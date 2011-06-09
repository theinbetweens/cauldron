class LengthEqual < InstanceCall
  
  def initialize
    
  end
  
  def write 
    return '.length ='
  end
  
  def copy
    return LengthEqual.new
  end  
  
end