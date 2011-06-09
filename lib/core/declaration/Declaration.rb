class Declaration < Array
  
  def initialize(val)
    super()
    @value = val
  end
  
  def write
    return @value
  end
  
  def copy
    return Declaration.new(@value.clone)
  end
    
end
