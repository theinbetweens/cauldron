module Code
  
  def initialize
    
  end
  
  def write(method_context=nil)
    raise StandardError.new('write method needs defined for '+self.class.to_s)
  end
  
end