class Do
  include Code 
  
  def initialize
    super  
  end
  
  def write(method_context=nil)
    return 'do'
  end  
  
  def copy
    return Do.new
  end
  
  def creation
    return 'Do.new'
  end  
  
end
