class LiteralClass < ClassName
  
 def initialize
    super 
  end

  def write(context=nil)
    return 'Literal'
  end
  
  def copy
    return LiteralClass.new
  end

  def value
    return Literal
  end  
  
end