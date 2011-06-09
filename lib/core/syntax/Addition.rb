# TODO  Move to InstanceCall

class Addition < InstanceCall
  
  def initialize
    
  end
  
  def copy
    return self.class.new
  end
  
  def write
    return ' +'
  end
  
  def to_literal_string
    return write
  end

  def closure
    return [' ','']
  end       
    
end