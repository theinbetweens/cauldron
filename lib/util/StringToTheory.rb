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
      'IfStatement'=>'IfStatementClass',
      'Return'=>'ReturnClass',
      'InstanceCallContainer'=>'InstanceCallContainerClass',
      'StringLength'=>'StringLengthClass',
      'Parser'=>'ParserClass',
      'Unknown'=>'UnknownClass',
      'Addition'=>'AdditionClass',
      'Equal'=>'EqualClass',
      'RuntimeMethod'=>'RuntimeMethodClass',
      'CTestCase'=>'CTestCaseClass',
      'Fixnum'=>'FixnumClass',
      'Equivalent'=>'EquivalentClass',
      'OpenStatement'=>'OpenStatementClass',
      'IfContainer'=>'IfContainerClass',
      'BlockStatement'=> 'BlockStatementClass',
      'Container'=> 'ContainerClass',
      'Subtract'=> 'SubtractClass',
      'Times'=> 'TimesClass',
      'Chop'=> 'ChopClass'
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
      #IfContainer.new(
      #  parse_token(sexp[1])
      #),
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
  
end