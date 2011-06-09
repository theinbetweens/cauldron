class Assignment
  
  def initialize
  end

  def write
    return self.class.to_s+' has not be described yet'
  end  
  
  def describe
    return write
  end
  
  def copy
    return self.class.new
  end  
  
end