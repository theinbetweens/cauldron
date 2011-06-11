$LOAD_PATH << File.expand_path('../../../../lib',__FILE__)

require 'required'
require 'test/unit'

class TestStringToTheory < Test::Unit::TestCase
  
  def setup
    
  end
  
  def teardown
    System.reset
    RuntimeMethod.reset_global_id
  end  
  
  def test_run_1
    assert(StringToTheory.run('var6 = 8').kind_of?(Statement))
    assert_equal("#{TheoryVariable.variable_colour(4)}var4#{TheoryVariable::NORMAL} = 7",StringToTheory.run('var4 = 7').describe)
    assert_equal(9,StringToTheory.run('var8 = 9')[2].value)
    assert(StringToTheory.run('var8 = 9')[0].kind_of?(TheoryVariable))
    assert_equal(8,StringToTheory.run('var8 = 9')[0].theory_variable_id)
  end
  
  def test_run_2
    assert_equal(
      "#{TheoryVariable.variable_colour(5)}var5#{TheoryVariable::NORMAL} = 'enterprise'",
      StringToTheory.run("var5 = 'enterprise'").describe
    )
    assert_equal(5,StringToTheory.run("var5 = 'enterprise'")[0].theory_variable_id)
    assert_equal("'enterprise'",StringToTheory.run("var5 = 'enterprise'")[2].describe)
    assert_equal(3,StringToTheory.run("var5 = 'enterprise'").length)
  end
  
  def test_run_3
    assert_raises(StandardError){StringToTheory.run("var4 = sadfasfdsa")}
  end
  
  def test_run_4
    assert_equal(
      'runtime_method.params[0].length',
      StringToTheory.run('runtime_method.params[0].length').write
    )
  end
  
  def test_run_instance_calls
    assert_equal(
      "#{TheoryVariable.variable_colour(8)}var8#{TheoryVariable::NORMAL} = #{TheoryVariable.variable_colour(6)}var9#{TheoryVariable::NORMAL}.chop",
      StringToTheory.run("var8 = var9.chop").describe
    )
    assert_equal(
      "#{TheoryVariable.variable_colour(8)}var8#{TheoryVariable::NORMAL} = #{TheoryVariable.variable_colour(9)}var9#{TheoryVariable::NORMAL}.length",
      StringToTheory.run("var8 = var9.length").describe
    )
  end
  
  # NOTE  I need to create the theories like real statements since I'm 
  #       using the Racc:Parser.
  # 
  def test_run_with_if_statement
    assert_equal(
      "#{TheoryVariable.variable_colour(6)}var6#{TheoryVariable::NORMAL}[7]",
      StringToTheory.run("var6[7]").describe
    )        
    assert_equal(
      "#{TheoryVariable.variable_colour(6)}var6#{TheoryVariable::NORMAL} == 7",
      StringToTheory.run("var6 == 7").describe
    )    
    assert_equal(
      "if(#{TheoryVariable.variable_colour(6)}var6#{TheoryVariable::NORMAL} == 7)\nend\n",
      StringToTheory.run("if(var6 == 7)\nend").describe
    )      
    assert_equal(
      "if(#{TheoryVariable.variable_colour(1)}var1#{TheoryVariable::NORMAL} == #{TheoryVariable.variable_colour(2)}var2#{TheoryVariable::NORMAL})\nend\n",
      StringToTheory.run("if(var1 == var2)\nend").describe
    )
    assert_equal(
      "if(#{TheoryVariable.variable_colour(1)}var1#{TheoryVariable::NORMAL}.length == #{TheoryVariable.variable_colour(2)}var2#{TheoryVariable::NORMAL}.length)\nend\n",
      StringToTheory.run("if(var1.length == var2.length)\nend").describe
    )
    assert(StringToTheory.run("if(var1.length == var2.length)\nend\n").kind_of?(OpenStatement))
  end
  
  def test_run_with_a_return
    assert_equal(
      "return #{TheoryVariable.variable_colour(8)}var8#{TheoryVariable::NORMAL}",
      StringToTheory.run('return var8').describe
    ) 
    assert_equal(
      'TheoryStatement',
      StringToTheory.run('return var8').class.to_s
    )
  end
  
  def test_variable_assignment
    a = StringToTheory.run("var1.length = var2.length")
    assert_equal(
      "#{TheoryVariable.variable_colour(1)}var1#{TheoryVariable::NORMAL}.length = #{TheoryVariable.variable_colour(2)}var2#{TheoryVariable::NORMAL}.length",    
      StringToTheory.run("var1.length = var2.length").describe
    )
  end
  
  def test_run_with_action_1
    assert_equal(
      "Statement.new(Return.new, #{TheoryVariable.variable_colour(1)}var1#{TheoryVariable::NORMAL}.params[0])",
      StringToTheory.run('Statement.new(Return.new, var1.params[0])').describe
    )
  end
  
  def test_run_instance_declaration
    assert_equal(
      "Statement.new(Return.new, InstanceCallContainer.new(#{TheoryVariable.variable_colour(1)}var1#{TheoryVariable::NORMAL}.params[0], StringLength.new))",
      StringToTheory.run('Statement.new(Return.new,InstanceCallContainer.new(var1.params[0], StringLength.new))').describe
    )
  end
  
  def test_run_with_a_addition_statement
    assert_equal(
      'Statement.new(Parser.run)',
      StringToTheory.run('Statement.new(Parser.run)').write
    )
    assert_equal(
      "Statement.new(Parser.run('var1 = var3'))",
      StringToTheory.run('Statement.new(Parser.run("var1 = var3"))').write
    )
    assert_equal(
      "Statement.new(Parser.run('var1 = var3 + var4'))",
      StringToTheory.run("Statement.new(Parser.run(\"var1 = var3 + var4\"))").write
    )    
  end
  
  def test_run_with_inline_declarations
    assert_equal(
      "Parser.run('var = var1 + var2')",
      StringToTheory.run('Parser.run("var = var1 + var2")').write
    )
    assert_equal(
      true,
      StringToTheory.run('Parser.run("var = var1 + var2")').kind_of?(ClassMethodCallContainer)
    )
    theory_statement = TheoryStatement.new(StringToTheory.run('Parser.run("var = var1 + var2")'))
    #
    # TODO  Currently this wouldn't be true because 'var = var1 + var2' is parsed as 
    #       a single string.  I'm not sure I want to go down that road.
    #assert_equal(2,theory_statement.select_all?({|x| x.kind_of?(TheoryVariable)})
  end
  
  def test_run_with_addition_statement_declaration
    assert_equal(    
      "Statement.new(Unknown.new, Equal.new, #{TheoryVariable.variable_colour(4)}var4#{TheoryVariable::NORMAL}.params[0], Addition.new, #{TheoryVariable.variable_colour(4)}var4#{TheoryVariable::NORMAL}.params[1])",
      StringToTheory.run('Statement.new(Unknown.new, Equal.new, var4.params[0], Addition.new, var4.params[1])').describe
    )
  end
  
  def test_run_with_kind_of_statement
    assert_nothing_raised(){
      StringToTheory.run("if(var1.kind_of?(RuntimeMethod))\nend")
    }  
    assert_equal(
      "if(#{TheoryVariable.variable_colour(1)}var1#{TheoryVariable::NORMAL}.kind_of?(RuntimeMethod))\nend\n",
      StringToTheory.run("if(var1.kind_of?(RuntimeMethod))\nend").describe
    )
    assert_nothing_raised(){
      StringToTheory.run("if(var1.kind_of?(Fixnum))\nend")
    }      
  end
  
  def test_run_with_history_calls
    # <history>.any? { |var1| var1.include? <statement>.id }
    assert_nothing_raised(){ StringToTheory.run("var1.any? { |var3| var2.include? var3.statement_id }") }
  end    
  
  def test_run_with_complex_block_statement
    assert_nothing_raised() {
      StringToTheory.run("var1.any? do |var3|\nvar2 = var1.chop\nend")
    }
    assert_equal(
      "#{TheoryVariable.variable_colour(1)}var1#{TheoryVariable::NORMAL}.any?{ |#{TheoryVariable.variable_colour(3)}var3#{TheoryVariable::NORMAL}| #{TheoryVariable.variable_colour(2)}var2#{TheoryVariable::NORMAL} = #{TheoryVariable.variable_colour(1)}var1#{TheoryVariable::NORMAL}.chop} ",
      StringToTheory.run("var1.any? do |var3|\nvar2 = var1.chop\nend").describe
    )
  end
  
  def test_run_with_kind_of_ctest_case
    assert_nothing_raised(){
      StringToTheory.run("var1.kind_of?(CTestCase)")
    }
    assert_equal(
      "#{TheoryVariable.variable_colour(1)}var1#{TheoryVariable::NORMAL}.kind_of?(CTestCase)",
      StringToTheory.run("var1.kind_of?(CTestCase)").describe
    )    
  end
  
  def test_statements_are_not_equal

    assert_nothing_raised(){
      StringToTheory.run("var1 != var2")
    }    
    
    # e.g. <var2>[<var3>][:params][<var6>] != <var2>[<var4>][:params][<var6>]
    assert_nothing_raised(){
      StringToTheory.run("var2[var3][:params][var6] != var2[var4][:params][var6]")
    }
    assert_equal(
      "#{TheoryVariable.variable_colour(2)}var2#{TheoryVariable::NORMAL}[#{TheoryVariable.variable_colour(3)}var3#{TheoryVariable::NORMAL}][:params][#{TheoryVariable.variable_colour(6)}var6#{TheoryVariable::NORMAL}] != #{TheoryVariable.variable_colour(2)}var2#{TheoryVariable::NORMAL}[#{TheoryVariable.variable_colour(4)}var4#{TheoryVariable::NORMAL}][:params][#{TheoryVariable.variable_colour(6)}var6#{TheoryVariable::NORMAL}]",      
      StringToTheory.run("var2[var3][:params][var6] != var2[var4][:params][var6]").describe
    )
  end
  
  def test_not_pass
#    assert_equal(
#      "if(!var1.pass?(var2[var4]))\nend",

      # TODO Doesn't appear to differentiate - is it a problem with the parser
      # StringToTheory.run("if(!var1.pass?(var2[var4]))\nend").write
      # StringToTheory.run("if(var1.pass?(var2[var4]))\nend").write
    #)
    assert_nothing_raised(){StringToTheory.run("if(var1.pass?(var2[var4])==false)\nend")}
    assert_equal(
      "if(var1.pass?(var2[var4]) == false)\nend",
      StringToTheory.run("if(var1.pass?(var2[var4])==false)\nend").write
    )
             
  end
  
  def test_double_negative
    assert_equal(
      "if((var2 == var3) == false)\n\treturn true\nend",
      StringToTheory.run("if((var2 == var3)== false)\nreturn true\nend").write
    ) 
    assert_equal(
     "if((var1.history(var2[var4][:params]).any?{ |x| x.statement_id == var8.statement_id} ) == false)\nend",
     StringToTheory.run("if((var1.history(var2[var4][:params]).any?{ |x| x.statement_id == var8.statement_id})==false )\nend").write
    ) 
    assert_equal(
      "if(var1.history(var2[var4][:params]).any?{ |x| x.statement_id != var8.statement_id} )\nend",
      StringToTheory.run("if(var1.history(var2[var4][:params]).any? { |x| x.statement_id != var8.statement_id })\nend").write
    )    
  end
    
  def test_custom_statements_1
    # e.g. <var9> == (<var5>[:params][<var6>].length+1)
    assert_nothing_raised(){
      StringToTheory.run("var9 == (var5[:params][var6].length+1)")
    }
    assert_nothing_raised(){
      StringToTheory.run("if(var9 == (var5[:params][var6].length+1))\nend")
    }    
    assert_nothing_raised(){
      StringToTheory.run("IfStatement.new(var2[var3][:params][var6],Equivalent.new,var2[var3][:output])")
    }
    assert_equal(
      5,
      StringToTheory.run("IfStatement.new(var2[var3][:params][var6],Equivalent.new,var2[var3][:output])").select_all {|x| x.kind_of?(ArrayAccess)}.length
    )
    # <var1>.history(<var2>[<var3>][:params]).any? { |x| x.statement_id == <var8>.statement_id }
    assert_nothing_raised(){
      StringToTheory.run("var1.history(var2[var3][:params]).any? { |x| x.statement_id == var8.statement_id }")
    }
    assert_nothing_raised(){
      StringToTheory.run("if(var1.history(var2[var3][:params]).any? { |x| x.statement_id == var8.statement_id })\nend")
    }    
    # <var1>.history(<var2>[<var4>][:params]).any? { |x| x.statement_id != <var8>.statement_id }
    assert_nothing_raised(){
      StringToTheory.run("var1.history(var2[var4][:params]).any? { |x| x.statement_id != var8.statement_id }")
    }
    assert_nothing_raised(){
      StringToTheory.run("if(var1.history(var2[var4][:params]).any? { |x| x.statement_id != var8.statement_id })\nend")
    }     
    assert_equal(
      "if(var1.history(var2[var4][:params]).any?{ |x| x.statement_id != var8.statement_id} )\nend",
      StringToTheory.run("if(var1.history(var2[var4][:params]).any? { |x| x.statement_id != var8.statement_id })\nend").write
    )
    assert_equal(
      "if((var1.history(var2[var4][:params]).any?{ |x| x.statement_id == var8.statement_id} ) == false)\nend",
      StringToTheory.run("if((var1.history(var2[var4][:params]).any?{ |x| x.statement_id == var8.statement_id})==false )\nend").write
    )    
    assert_equal(
      "Statement.new(Return.new, var2[var3][:output])",
      StringToTheory.run("Statement.new(Return.new,var2[var3][:output])").write
    )
    assert_equal(
      "var1.pass?(var2[var3])",
      StringToTheory.run("var1.pass?(var2[var3])").write
    )
    assert_not_equal(
      "var1.pass?(var2[var3])",
      StringToTheory.run("var1.pass?(var2[var4])").write
    )
    # The parser doesn't seem to support the ! syntax here
    assert_not_equal(
      "if(!var1.pass?(var2[var4]))\nend",
      StringToTheory.run("if(!var1.pass?(var2[var4]))\nend").write
    )    
    assert_equal(
        "if((var2[var3] == var2[var4]) == false)\n\treturn true\nend",
        StringToTheory.run("if((var2[var3] == var2[var4])== false)\nreturn true\nend").write
    )
  end
  
end