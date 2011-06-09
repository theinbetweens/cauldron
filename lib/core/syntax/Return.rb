
class Return 
  include Code
  
  def initialize
    super
  end
  
  def write(method_context=nil)
    return 'return'
  end
  
  def describe
    return write
  end
 
  def copy
    return Return.new
  end
  
  def creation
    return 'Return.new'
  end
  
  def to_declaration
    return VariableDeclaration.new(self.class.to_s)
  end
  
  def to_literal_string
    return write
  end
    
end