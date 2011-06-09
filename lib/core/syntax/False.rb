class False < Boolean
  
  def initialize
    super
  end
  
  def write(context=nil)
    return 'false'
  end
  
  
end