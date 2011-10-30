#
#  var6 = 8
#  s(:lasgn, :var6, s(:lit, 8))
#
#  var6.length = 8
#  s(:attrasgn, s(:call, nil, :var6, s(:arglist)), :length=, s(:arglist, s(:lit, 8)))
#
#  return var8
#  s(:return, s(:call, nil, :var8, s(:arglist)))
#
#  var6[7]
#  s(:call, s(:call, nil, :var6, s(:arglist)), :[], s(:arglist, s(:lit, 7)))
#
#  var1.length = var2.length
#  s(:attrasgn, s(:call, nil, :var1, s(:arglist)), :length=, s(:arglist, s(:call, s(:call, nil, :var2, s(:arglist)), :length, s(:arglist))))
#
#  var6 == 7
#  s(:call, s(:call, nil, :var6, s(:arglist)), :==, s(:arglist, s(:lit, 7)))
#
#  if(var6 == 7)
#  end
#  s(:if, s(:call, s(:call, nil, :var6, s(:arglist)), :==, s(:arglist, s(:lit, 7))), nil, nil)
#
#   Statement.new(Return.new,var1.params[0])
#   s(:call, s(:const, :Statement), :new, s(:arglist, s(:call, s(:const, :Return), :new, s(:arglist)), s(:call, s(:call, s(:call, nil, :var1, s(:arglist)), :params, s(:arglist)), :[], s(:arglist, s(:lit, 0)))))
#
#   var1.any? { |x| x.include? var2.id }
#   s(:iter, s(:call, s(:call, nil, :var1, s(:arglist)), :any?, s(:arglist)), s(:lasgn, :x), s(:call, s(:lvar, :x), :include?, s(:arglist, s(:call, s(:call, nil, :var2, s(:arglist)), :id, s(:arglist)))))
#
#   var1.any? do |x|
#     var2 = var1.chop
#   end
#   s(:iter, s(:call, s(:call, nil, :var1, s(:arglist)), :any?, s(:arglist)), s(:lasgn, :x), s(:lasgn, :var2, s(:call, s(:call, nil, :var1, s(:arglist)), :chop, s(:arglist))))
# 
class StringToTheory < Parser
  
  # Converts a string into a theory statement.
  # 
  # e.g. "var8 = 7" -> TheoryStatement.new(...)  
  #
  def self.run(statement_string)
    statement_string.gsub!(/<runtime_method>/,'runtime_method')
    return super(statement_string)
    
  end
  
  def self.create_dependent(statement_string)
    return TheoryDependent.new(self.run("if("+statement_string+")\nreturn true\nend"))
  end
  
  def self.create_result(statement_string)
    return TheoryResult.new(self.run("if("+statement_string+")\nreturn true\nend"))
  end
  
  def self.create_action(statement_string,insert_location,variable_values)
    
    # Add the standard substitions 
    variable_values['return'] = 'Return.new'
    variable_values['=='] = 'Equivalent.new'
    
    statement_elements = statement_string.split(/\s/)
    if statement_string.include?('if')
      statement_elements.delete_if {|x| x == 'if'}
      updated_elements = statement_elements.collect do |element|
        variable_values.has_key?(element) ? variable_values[element] : element
      end
      return TheoryAction.new(
        TheoryStatement.new(
          self.run(
            'OpenStatement.new(TheoryStatement.new(If.new,Container.new('+updated_elements.join(',')+')))'
          )
        ),
        self.run(insert_location)
      )      
    else
      updated_elements = statement_elements.collect do |element|
        variable_values.has_key?(element) ? variable_values[element] : element
      end
      return TheoryAction.new(
        TheoryStatement.new(self.run('Statement.new('+updated_elements.join(',')+')')),
        self.run(insert_location)
      )
    end
  end
  
  # TODO  This method is very similar to the Parser
  def self.parse_simple_token(token)
    if token.to_s.match(/^var(\d+)$/)
      id = token.to_s.match(/^var(\d+)$/)[1].to_i
      return TheoryVariable.new(id)
    end
    if token.to_s.match(/^[x|y|z]$/) then return BlockToken.new(token.to_s) end
    return Equal.new if token == '='
    return Return.new if token == :return
    return LengthEqual.new if token == :length=
    return Equivalent.new if token == :==
    raise StandardError.new("Could not identify simple token '#{token.to_s}'")
  end
 
  def self.parse_const(token)
    constants = {
      'Statement'=>'StatementClass',
      'Return'=>'ReturnClass',
      'InstanceCallContainer'=>'InstanceCallContainerClass',
      'StringLength'=>'StringLengthClass',
      'Parser'=>'ParserClass',
      'Unknown'=>'UnknownClass',
      'Addition'=>'AdditionClass',
      'Equal'=>'EqualClass',
      'If'=>'IfClass',
      'RuntimeMethod'=>'RuntimeMethodClass',
      'CTestCase'=>'CTestCaseClass',
      'Fixnum'=>'FixnumClass',
      'Equivalent'=>'EquivalentClass',
      'OpenStatement'=>'OpenStatementClass',
      'BlockStatement'=> 'BlockStatementClass',
      'Container'=> 'ContainerClass',
      'Subtract'=> 'SubtractClass',
      'Times'=> 'TimesClass',
      'Chop'=> 'ChopClass',
      'TheoryStatement'=> 'TheoryStatementClass'
    }
    raise StandardError.new('Unkown constant '+token.to_s) unless constants.has_key?(token.to_s)
    eval(constants[token.to_s]+'.new')
  end 
 
   def self.parse_custom_token(sexp)
    if sexp[2].to_s.match(/^var(\d+)$/)
      id = sexp[2].to_s.match(/^var(\d+)$/)[1].to_i
      return TheoryVariable.new(id)
    elsif sexp[2].to_s.match(/^runtime_method$/)
      return IntrinsicRuntimeMethod.new
    elsif sexp[2].to_s.match(/^test_cases$/)
      return IntrinsicTestCases.new
    else
      raise StandardError.new('Could not match '+sexp[2].to_s)
    end    
  end
  
  def self.parse_if(sexp)
    # TODO  Look into the change in the nil position
    # 
    # "if(var2 == var3)\nreturn true\nend"
    # s(:if, s(:call, s(:call, nil, :var2, s(:arglist)), :==, s(:arglist, s(:call, nil, :var3, s(:arglist)))), s(:return, s(:true)), nil)
    #
    # "if(var2 != var3)\nreturn true\nend"
    # s(:if, s(:call, s(:call, nil, :var2, s(:arglist)), :==, s(:arglist, s(:call, nil, :var3, s(:arglist)))), nil, s(:return, s(:true)))
    #      
    internal_statements = (2...sexp.length).inject([]) do |total,x| 
      total << sexp[x] unless sexp[x].nil?
      total
    end 
    return OpenStatement.new(
      TheoryStatement.new(
        If.new,
        Container.new(parse_token(sexp[1]))
      ),
      *internal_statements.collect {|x| parse_token(x)}
    )      
    
  end  
  
  def self.parse_return(sexp)
    return TheoryStatement.new(
      *[sexp[0],sexp[1]].collect {|x| parse_token(x)}
    )       
  end  
  
  def self.parse_attrasgn(sexp)
    # TODO  Make a note of this change - the equal(=) is with the method call here 
    return TheoryStatement.new(
      InstanceCallContainer.new(
        parse_token(sexp[1]),
        parse_token(sexp[2])
      ),
      *parse_token(sexp[3])
    )         
    
  end  
  
  def self.parse_token(sexp,affirmative=true,depth=0)    
    unless sexp.kind_of?(Sexp)
      return parse_simple_token(sexp)
    end
    
    # Generate any single literals
    if sexp[0] == :lit || sexp[0] == :str
      return Literal.new(sexp[1])
    end  
    
    if sexp[0] == :call
      if sexp[1].kind_of?(Sexp)
        if sexp[2] == :[] 
          # TODO  This doesn't identity hash containers - I don't know if that matters
          #return ArrayAccess.new(parse_token(sexp[1]),self.parse_token(sexp[3]).pop)
          return ArrayAccess.new(parse_token(sexp[1]),*self.parse_token(sexp[3]))
        elsif sexp[2] == :==
          # TODO  This should be a Statement - and TheoryStatemetn StringToTheory
          
          # Only have one statement per level
          if depth > 0
            #c = Container.new(*(1...sexp.length).collect {|x| parse_token(sexp[x],true,depth+1)})
            c = Container.new(parse_token(sexp[1],true,depth+1),parse_token(sexp[2],true,depth+1),*parse_token(sexp[3],true,depth+1))
            return c
          else
            return TheoryStatement.new(
              parse_token(sexp[1],true,depth+1),self.identify_method(sexp[2],affirmative),*parse_token(sexp[3])
            )
          end
        else
          
          if parse_token(sexp[1]).kind_of?(ClassName)
            return ClassMethodCallContainer.new(parse_token(sexp[1]),self.identify_method(sexp[2],affirmative),*parse_token(sexp[3]))
          else
            return TheoryStatement.new(InstanceCallContainer.new(
                      parse_token(sexp[1]),
                      self.identify_method(sexp[2],affirmative),
                      *parse_token(sexp[3]))
            )
          end          
          
        end
      else
        return self.parse_custom_token(sexp)
      end
    end
    
    if sexp[0] == :arglist
      if sexp[1].nil?
        return [] 
      end
      return (1...sexp.length).collect {|x| parse_token(sexp[x])}
    end
    
    # Catch if it is a statement
    if sexp[0] == :lasgn
      return parse_lasgn(sexp)
    end
    if sexp[0] == :return
      return self.parse_return(sexp)
    end
    
    if sexp[0] == :if
      return self.parse_if(sexp)
    end
    
    if sexp[0] == :attrasgn
      return parse_attrasgn(sexp)
    end
    
    if sexp[0] == :true
      return True.new
    end
    
    if sexp[0] == :false
      return False.new
    end
    
    if sexp[0] == :next
      return Next.new
    end
    
    if sexp[0] == :const
      return parse_const(sexp[1])
    end
    
    if sexp[0] == :lvar
      return parse_simple_token(sexp[1])
    end
    
    if sexp[0] == :not
      return parse_token(sexp[1],false)
    end
    
    # NOTE: This relates to blocks
    # var1.any? { |x| x.include? var2.id } => [ [1] => :call, [2] => :lasgn, [3] => :call ]
    # var1.any? do |x| var2 = var1.chop end => [ [1] => :call, [2] => :lasgn, [3] => :lasgn ]
    if sexp[0] == :iter
      if depth > 0 
        return Container.new(parse_iter(sexp))
      else
        return parse_iter(sexp)
      end
    end
    
    raise StandardError.new("Could not find sexp '#{sexp[0].to_s}'")
  end    
  
end