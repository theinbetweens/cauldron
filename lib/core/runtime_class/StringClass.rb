class StringClass < ClassName
  
	def initialize
    super 
	end

  def write(context=nil)
    return 'String'
  end  
  
  def copy
    return StringClass.new
  end

  def value
    return String
  end

  def declaration_statement
    return ClassMethodCallContainer.new(StringClass.new,New.new)
  end
  
end