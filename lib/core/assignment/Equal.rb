# Reflects the use of the (=)
#

class Equal < Equivalent
  
  def initialize
    super
  end
  
  def write()
    return ' = '
  end
  
  def describe
    return write
  end
  
  def copy
    return Equal.new
  end
  
  def declaration_statement
    return ClassMethodCallContainer.new(EqualClass.new,New.new)    
  end
  
  def to_literal_string
    return '='
  end
  
  def to_declaration
    return VariableDeclaration.new(self.class.to_s)
  end
  
  def equivalent?(to)
    return true if to.class == self.class
    return false    
  end
  
end