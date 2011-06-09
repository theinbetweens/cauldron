class Next 
  include Code
  
  def initialize
    super
  end
  
  def write(tab=0)
    return ("\t"*tab)+'next'
  end
 
  def copy
    return Next.new
  end
  
  def to_declaration
    return VariableDeclaration.new(self.class.to_s)
  end
  
  def to_literal_string
    return write
  end
    
end