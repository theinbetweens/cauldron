class Fixnum
  
  def to_var(id=nil,uniq_id=nil)
    return FixnumVariable.new(self,id) {{:variable_id => id,:uniq_id=>uniq_id}}
  end  
  
  def copy
    return self
  end
  
  def to_declaration
    return LiteralDeclaration.new(self)    
  end
  
  def write
    return self.to_s
  end  
  
  def describe
    write
  end
  
  def to_literal
    return Literal.new(self)
  end
  
  def to_literal_string
    return write
  end
  
  def cauldron_method_calls
    return ['.kind_of?']
  end
  
  def to_intrinsic
    return IntrinsicLiteral.new(self)  
  end
    
end