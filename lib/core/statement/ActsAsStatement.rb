# This module is shared between the Statement and BlockStatement classes.  It 
# ensures that both those classes have a statement id and a structure type.
#
module ActsAsStatement
  
  # TODO  I think I should start to fade out statement_type - I should start by finding calls where it
  #       is needed.
  def statement_type
    if @statement_type.nil?
      @statement_type = identify_statement_type
    end
    raise UnknownStatementType.new('No statement type has been defined for this statement "'+self.write+'" ['+self.class.to_s+']') if @statement_type.nil?
    return @statement_type
  end
  
  # Returns true if the statement (treated as an array) has all the
  # same classes as the array supplied.
  # 
  # @param  classes     An array of classes that this statement is 
  #                     compared to.
  #
  def classes_match?(*classes)
    return false unless classes.length == self.length
    self.zip(classes) do |x,y|  
      return false unless x.instance_of?(y)
    end
    return true
  end    
  
protected
  
  # Attempts to identify the type of statement this is by its contents.
  #
  def identify_statement_type
    case self.length
      when 0
        return StatementStructure::BLANK_STATEMENT     
      when 1
        return StatementStructure::IF_STATEMENT if first.kind_of?(If)
        #return StatementStructure::USAGE_STATEMENT if self.classes_match?(InstanceCallContainer)
        if self.classes_match?(InstanceCallContainer)
          if first.method_call.destructive?
            return StatementStructure::MODIFYING_STATEMENT
          else
            return StatementStructure::USAGE_STATEMENT 
          end
        end
        # TODO  Not sure if this should be a usage_statement
        return StatementStructure::USAGE_STATEMENT if self.classes_match?(DefCall) 
        
      when 2
        return StatementStructure::RETURN_STATEMENT if first.kind_of?(Return)
      when 3
        # TODO  This should distinguish between modifying statements e.g. chop! and push
        # var = var.chop
        return StatementStructure::DECLARATION_STATEMENT if self.classes_match?(Unknown,Equal,InstanceCallContainer) 
        return StatementStructure::DECLARATION_STATEMENT if self.classes_match?(Unknown,Equal,ClassMethodCallContainer)         
        # TODO  Is there a difference between a Literal and a LiteralDeclaration
        return StatementStructure::DECLARATION_STATEMENT if self.classes_match?(Unknown,Equal,Literal) 
        return StatementStructure::DECLARATION_STATEMENT if self.classes_match?(Unknown,Equal,StringVariable)         
        return StatementStructure::DECLARATION_STATEMENT if self.classes_match?(Unknown,Equal,ArrayVariable)                 
        return StatementStructure::DECLARATION_STATEMENT if self.classes_match?(Unknown,Equal,FixnumVariable)         
        return StatementStructure::DECLARATION_STATEMENT if self.classes_match?(Unknown,Equal,StatementVariable)         
        return StatementStructure::DECLARATION_STATEMENT if self.classes_match?(Unknown,Equal,RuntimeMethodParameter)        
        return StatementStructure::DECLARATION_STATEMENT if self.classes_match?(Unknown,Equal,LiteralDeclaration)
        return StatementStructure::DECLARATION_STATEMENT if self.classes_match?(Unknown,Equal,NilVariable)
        return StatementStructure::DECLARATION_STATEMENT if self.classes_match?(Unknown,Equal,DefCall)        
        return StatementStructure::DECLARATION_STATEMENT if self.classes_match?(Unknown,Equal,Fixnum)        
        return StatementStructure::DECLARATION_STATEMENT if self.classes_match?(Unknown,Equal,UnknownVariable)                
        return StatementStructure::DECLARATION_STATEMENT if self.classes_match?(StringVariable,Equal,Literal) 
        return StatementStructure::DECLARATION_STATEMENT if self.classes_match?(StringVariable,Equal,LiteralDeclaration)         
        return StatementStructure::DECLARATION_STATEMENT if self.classes_match?(StringVariable,Equal,DefCall)                 
        return StatementStructure::DECLARATION_STATEMENT if self.classes_match?(StringVariable,Equal,ArrayAccess)                         
        return StatementStructure::DECLARATION_STATEMENT if self.classes_match?(FixnumVariable,Equal,InstanceCallContainer)                 
        return StatementStructure::DECLARATION_STATEMENT if self.classes_match?(FixnumVariable,Equal,Literal)                         
        return StatementStructure::DECLARATION_STATEMENT if self.classes_match?(FixnumVariable,Equal,DefCall)                                 
        return StatementStructure::DECLARATION_STATEMENT if self.classes_match?(ArrayVariable,Equal,Literal)                                 
        return StatementStructure::DECLARATION_STATEMENT if self.classes_match?(ArrayVariable,Equal,DefCall)                                         
        return StatementStructure::DECLARATION_STATEMENT if self.classes_match?(StatementVariable,Equal,DefCall)                                         
        return StatementStructure::DECLARATION_STATEMENT if self.classes_match?(VariableContainer,Equal,Literal)            
        # TODO  I don't know if this should be possible/allowed
        return StatementStructure::DECLARATION_STATEMENT if self.classes_match?(Unknown,Equal,Unknown)                
        # TODO  I'm not sure whether ArrayAccess should be USAGE_STATEMENT
        return StatementStructure::DECLARATION_STATEMENT if self.classes_match?(Unknown,Equal,ArrayAccess)                         
        return StatementStructure::DECLARATION_STATEMENT if self.classes_match?(StringVariable,Equal,InstanceCallContainer)
        return StatementStructure::DECLARATION_STATEMENT if self.classes_match?(MethodUsageVariable,Equal,ClassMethodCallContainer)
        return StatementStructure::DECLARATION_STATEMENT if self.classes_match?(StatementVariable,Equal,ClassMethodCallContainer)        
        return StatementStructure::DECLARATION_STATEMENT if self.classes_match?(RuntimeMethodParameter,Equal,DefCall)        
        return StatementStructure::DECLARATION_STATEMENT if self.classes_match?(UnknownVariable,Equal,InstanceCallContainer)        
        return StatementStructure::DECLARATION_STATEMENT if self.classes_match?(RuntimeMethodParameter,Equal,ClassMethodCallContainer)                
      when 5
        if self.classes_match?(Unknown,Equal,Unknown,Addition,Unknown)
          return StatementStructure::DECLARATION_STATEMENT 
        end        
        if self.classes_match?(Unknown,Equal,Unknown,Subtract,Unknown)
          return StatementStructure::DECLARATION_STATEMENT 
        end
        if self.classes_match?(Unknown,Equal,FixnumVariable,Addition,FixnumVariable)
          return StatementStructure::DECLARATION_STATEMENT 
        end
        if self.classes_match?(Unknown,Equal,InstanceCallContainer,Addition,InstanceCallContainer )
          return StatementStructure::DECLARATION_STATEMENT 
        end       
        if self.classes_match?(Unknown,Equal,MethodParameter,Addition,MethodParameter )
          return StatementStructure::DECLARATION_STATEMENT 
        end        
        return StatementStructure::DECLARATION_STATEMENT if self.classes_match?(Unknown,Equal,StringVariable,Addition,StringVariable)        
        # TODO  I don't know if I want this classed as a declaration statement since it might be replacing the
        #       value of a variable.
        return StatementStructure::DECLARATION_STATEMENT if self.classes_match?(FixnumVariable,Equal,FixnumVariable,Addition,FixnumVariable)        
    end 

    raise StandardError.new('Unable to determine statement type for "'+self.write+'"'+self.inject('') {|x,y| x += y.class.to_s+' : ' })
  end
  
end