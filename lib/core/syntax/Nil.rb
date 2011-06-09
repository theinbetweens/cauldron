class Nil
  
  def initialize  
  end
  
  def copy
    return self.class.new
  end
  
  def write
    return 'nil'
  end
    
  
end