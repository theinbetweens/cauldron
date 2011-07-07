class String
  
  def copy
    return self.clone
  end
  
  def declaration_statement
    return Statement.new(self.to_s)
  end
  
  def write
    x = self.escape_single_quotes
    return '\''+x+'\''
  end
  
  def instance_call_structures
    return [
      InstanceCallContainerStructure.new(StringVariable,Chop.new),
      InstanceCallContainerStructure.new(StringVariable,StringLength.new)
      ]
  end
  
  #
  # @param  id    You can specify the id of the newly created variable
  #
  def to_var(var_id=nil,unique_id=nil)
    return StringVariable.new(self,var_id){{:variable_id => var_id,:uniq_id=>unique_id}}
  end
  
  def to_declaration
    return LiteralDeclaration.new(self.clone)
  end

  def to_literal_string
    return write
  end
  
  def to_literal
    return Literal.new(self.clone)
  end 
  
  # Returns a statement declaring a variable with the value of
  # this string e.g. 
  #
  # 'Sparky'.to_declaration_statement -> var_x = 'Sparky'
  #
  def to_declared_variable_statement
    return Statement.new(StringVariable.new(self),Equal.new,self.to_declaration)
  end
    
  # http://snippets.dzone.com/posts/show/880
  # TODO  There is a BASH command `quote` and `quote_readline` that
  # might be more useful here.
  def escape_single_quotes
    return self.gsub(/[']/, '\\\\\'')    
  end
  
  def cauldron_method_calls
    return ['.length']
  end
  
end

