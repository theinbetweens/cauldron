class NilClass
  
  def to_var(id=nil)
    return NilVariable.new(id) {{:variable_id => id,:uniq_id=>nil}}
  end
  
  def to_declaration
    return LiteralDeclaration.new(nil)
  end
  
  def write
    return 'nil'
  end
  
  def copy
    return self
  end
  
end