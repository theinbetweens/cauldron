class Copy <InstanceCall
  
  def initialize
    super
    
    @use_requirements = []
    
  end
  
  def write
    return '.copy'
  end
  
  def copy
    return Copy.new
  end
  
  def use(val)
    return val.copy
  end
  
end