# Allows string to be converted into object code.
#
# Currently it can only generate objects as complex as statements, so it can't
# generate whole runtime methods or populated nested statements.
#
# http://rubydoc.info/gems/ruby_parser/2.0.5/frames
#
# http://www.rubyinside.com/treetop-powerful-but-easy-ruby-parser-library-701.html
# http://en.wikipedia.org/wiki/Yacc
# http://thingsaaronmade.com/blog/writing-an-s-expression-parser-in-ruby.html
#
# use StringScanner
#
# Ruby2Ruby 'ruby code' -> s-expression -> 'ruby code'
#
# 'test'
# s(:str, "test")
#
# var8
# s(:call, nil, :var8, s(:arglist))
#
# var8.length
# s(:call, s(:call, nil, :var8, s(:arglist)), :length, s(:arglist))
#
# 'new vegas'.length
# s(:call, s(:str, "new vegas"), :length, s(:arglist))
#
# runtime_method.params
# s(:call, s(:call, nil, :runtime_method, s(:arglist)), :params, s(:arglist))
#
# var_6[8]
# s(:call, s(:call, nil, :var_6, s(:arglist)), :[], s(:arglist, s(:lit, 8)))
#
# 'runtime_method.all_pass?(test_cases)' 
# s(:call, s(:call, nil, :runtime_method, s(:arglist)), :all_pass?, s(:arglist, s(:call, nil, :test_cases, s(:arglist))))
#
# 'var_1 = var_2 + var_3'
# s(:lasgn, :var1, s(:call, s(:call, nil, :var2, s(:arglist)), :+, s(:arglist, s(:call, nil, :var3, s(:arglist)))))
#
# var_2 = var_5.chop + var_2
# s(:lasgn, :var2, s(:call, s(:call, s(:call, nil, :var5, s(:arglist)), :chop, s(:arglist)), :+, s(:arglist, s(:lvar, :var2))))
# TODO  I need to move away from my instance call structure and more towards this - 
#       this + contains the arg ment so it just goes deeper down the stack.
#
# var1 != var2
# s(:not, s(:call, s(:call, nil, :var1, s(:arglist)), :==, s(:arglist, s(:call, nil, :var2, s(:arglist))))) 
#
#
class Parser

  def self.run(code)
    parser    = RubyParser.new
    #ruby2ruby = Ruby2Ruby.new
    sexp      = parser.process(code)

    return parse_token(sexp,true,0)
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
            return InstanceCallContainer.new(
                      parse_token(sexp[1]),
                      self.identify_method(sexp[2],affirmative),
                      *parse_token(sexp[3])
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
      Statement.new(
        If.new,
        Container.new(parse_token(sexp[1]))
      ),
      *internal_statements.collect {|x| parse_token(x)}
    )      
    
  end
  
  def self.parse_simple_token(token)
    if token.to_s.match(/^var(\d+)$/)
      id = token.to_s.match(/^var(\d+)$/)[1].to_i
      return Unknown.new(id)
    end
    return Equal.new if token == '='
    return Return.new if token == :return
    return LengthEqual.new if token == :length=
    raise StandardError.new("Could not identify simple token '#{token.to_s}':#{token.class.to_s}")
  end
  
  def self.parse_iter(sexp)
    # TODO  Only supports one BlockVariable
    
    # TODO  Not sure this is the best way to detmine whether to use "do end" or "{}" 
    if sexp.length == 4
      s= SingleLineBlockStatement.new(
        parse_token(sexp[1]),
        BlockContainer.new(parse_simple_token(sexp[2][1])),
        *(3...sexp.length).collect {|x| parse_token(sexp[x])}
      ) 
      return s
    else
      return BlockStatement.new(
        parse_token(sexp[1]),
        BlockContainer.new(parse_simple_token(sexp[2][1])),
        *(3...sexp.length).collect {|x| parse_token(sexp[x])}
      )
    end
  end
  
  def self.parse_const(token)
    constants = {'Statement'=>'StatementClass','Return'=>'ReturnClass'}
    raise StandardError.new('Unkown constant '+token.to_s) unless constants.has_key?(token.to_s)
    eval(constants[token.to_s]+'.new')
  end
  
  def self.parse_lasgn(sexp)
    return TheoryStatement.new(
      *[sexp[1],'=',sexp[2]].collect {|x| parse_token(x)}
    )    
  end
  
  def self.parse_return(sexp)
    return Statement.new(
      *[sexp[0],sexp[1]].collect {|x| parse_token(x)}
    )       
  end
  
  def self.parse_attrasgn(sexp)
    
    # TODO  Make a note of this change - the equal(=) is with the method call here
    return Statement.new(
      InstanceCallContainer.new(
        parse_token(sexp[1]),
        parse_token(sexp[2])
      ),
      *parse_token(sexp[3])
    )         
    
  end
  
  def self.parse_custom_token(sexp)
    if sexp[2].to_s.match(/^var(\d+)$/)
      id = sexp[2].to_s.match(/^var(\d+)$/)[1].to_i
      return Unknown.new {{:variable_id=>id}}
    elsif sexp[2].to_s.match(/^var_(\d+)$/)
      id = sexp[2].to_s.match(/^var_(\d+)$/)[1].to_i
      return Unknown.new {{:variable_id=>id}}      
    elsif sexp[2].to_s.match(/^runtime_method$/)
      return IntrinsicRuntimeMethod.new
    elsif sexp[2].to_s.match(/^test_cases$/)
      return IntrinsicTestCases.new
    elsif sexp[2].to_s.match(/^last_runtime_method$/)
      return IntrinsicLastRuntimeMethod.new      
    else
      raise StandardError.new('Could not match '+sexp[2].to_s)
    end    
  end
  
  def self.identify_method(method_name,affirmative=true)   
    method_calls = {
      'length'=>'StringLength',
      'params'=>'Params', 
      'value'=> 'Value', 
      'all_pass?'=>'AllPass',
      'pass?'=>'Pass',
      'push'=>'Push',
      '+'=>'Addition',
      '==' => 'Equivalent',
      'chop' => 'Chop',
      'realise2' => 'Realise',
      'new' => 'New',
      'run' => 'Run',
      'kind_of?' => 'KindOf',
      'history' => 'HistoryCall',
      'history2' => 'History2Call',
      'any?' => 'Any',
      'include?' => 'Include',
      'statement_id' => 'StatementID',
      'last' => 'Last',
      'select' => 'Select',
      '-' => 'Subtract'
    }
    # TODO  Need to re-structure code to better suit the parser and how it handles != statements
    if not affirmative
      method_calls = {
        '==' => 'NotEqual',
      }
    end
     raise StandardError.new('Unkown method call "'+method_name.to_s+'"') unless method_calls.has_key?(method_name.to_s)
     eval(method_calls[method_name.to_s]+'.new')
  end
  
end