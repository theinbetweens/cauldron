$LOAD_PATH << File.expand_path('../../../../lib',__FILE__)

require 'required'
require 'test/unit'

class TestTheoryDependent < Test::Unit::TestCase
  
  def setup
    # TODO  Need to include restriction so that theory dependents are always converted to if statements
    # @dependent_one = TheoryDependent.new("var1.length = var2.length") - > WRONG!
    @dependent_one = TheoryDependent.new(StringToTheory.run("if(var1.length = var2.length)\nend"))
    @dependent_two = TheoryDependent.new(StringToTheory.run("if(var1.value.length = var2.length)\nend"))
  end
  
  def teardown
    System.reset
    RuntimeMethod.reset_global_id    
  end
  
  def test_intialize
    assert_nothing_raised(){TheoryDependent.new(StringToTheory.run("if(var6 = 7)\nend"))}
    assert_nothing_raised(){TheoryDependent.new(StringToTheory.run("if(var6 == 7)\nend"))}
  end 
  
  def test_intialize_kind_of_statements
    assert_nothing_raised(){TheoryDependent.new(StringToTheory.run("if(var1.kind_of?(RuntimeMethod))\nreturn true\nend"))}
    assert_equal(
      true,
      TheoryDependent.new(StringToTheory.run("if(var1.kind_of?(RuntimeMethod))\nreturn true\nend")).describe.include?('return true')
    )
  end
  
  def test_intialize_with_addition_and_comparison
    assert_nothing_raised(){
      TheoryDependent.new(StringToTheory.run("if((var1 + var2) == var3)\nend"))
    }
    assert_equal(
      3,
      TheoryDependent.new(StringToTheory.run("if((var1 + var2) == var3)\nend")).theory_variables.length
    )
  end
  
  def test_intialize_with_block_statements
    assert_nothing_raised(){
      TheoryDependent.new(StringToTheory.run("if(var1.any? { |x| x.include? var2.statement_id })\nreturn true\nend"))
    }
    assert_equal(
      2,
      TheoryDependent.new(StringToTheory.run("if(var1.any? { |x| x.include? var2.statement_id })\nreturn true\nend")).theory_variables.length
    )    
  end    
  
  def test_intialize_with_if_statement_example
    assert_nothing_raised(){
      TheoryDependent.new(
        StringToTheory.run("if((var1.history(var2[var4][:params]).any?{ |x| x.statement_id == var8.statement_id} ) == false)\nend")
      )
    }
    assert_equal(
      4,    
      TheoryDependent.new(
        StringToTheory.run("if((var1.history(var2[var4][:params]).any?{ |x| x.statement_id == var8.statement_id} ) == false)\nend")
      ).theory_variables.length      
    )
  end
  
  def test_theory_variables
    assert_equal(2,@dependent_one.theory_variables.length)
    assert_equal(2,@dependent_two.theory_variables.length)
  end
  
  def test_copy
    a = StringToTheory.run("if(var1.length = var2.length)\nend")
    
  end
  
  def test_rewrite_with
    assert_raises(StandardError) {@dependent_one.rewrite_with([])}
    assert_equal(
      "if(runtime_method.params[0].length = test_cases[0][:output].length)\nend",
      @dependent_one.rewrite_with([
        InstanceCallContainer.new(IntrinsicRuntimeMethod.new,ArrayAccess.new(Params.new,0)),
        HashAccess.new(
          ArrayAccess.new(
            IntrinsicTestCases.new,
            0
          ),
          Literal.new(:output)
        )
      ]).write
    )
  end
  
  def test_rewrite_with_using_a_long_replacement
    assert_equal(
      "if(runtime_method.params[0].value.length = test_cases[0][:output].length)\nend",
      @dependent_one.rewrite_with([
        Parser.run('runtime_method.params[0].value'),
        Parser.run('test_cases[0][:output]')
      ]).write
    )
  end
  
  def test_rewrite_with_too_few_replacements
    assert_raises(StandardError){
      @dependent_one.rewrite_with([
        Parser.run('runtime_method.params[0].value')
      ])
    }
  end  
  
  def test_rewrite_permutations
    base_value_desc = [
      Parser.run('runtime_method[:params][0]'),
      Parser.run('test_cases[0][:params][0]'),
      Parser.run('test_cases[0][:output]'),
      Parser.run('test_cases[0][:params][0]'), 
      Parser.run('test_cases[1][:output]')     
    ] 
    assert_equal(20,@dependent_one.rewrite_permutations(base_value_desc).length)
    assert_equal(OpenStatement,@dependent_one.rewrite_permutations(base_value_desc).first.class)
  end
  
  def test_map_to_1
    dependent_one = TheoryDependent.new(StringToTheory.run("if(var2[var3].kind_of?(CTestCase))\nreturn true\nend"))
    mapping = {2=>IntrinsicTestCases.new,3=>Literal.new(0)}
    assert_equal(
      "if(<test_cases>[0].kind_of?(CTestCase))\n\treturn true\nend\n",
      dependent_one.map_to(mapping).describe
    )
  end
  
  def test_map_to_2
    dependent_two = TheoryDependent.new(StringToTheory.run("if(var6.kind_of?(Fixnum))\nreturn true\nend"))
    mapping = {6 => 0.to_literal}
    assert_equal(
      "if(0.kind_of?(Fixnum))\n\treturn true\nend\n",
      dependent_two.map_to(mapping).describe
    )
  end  
  
  def test_map_to_3
    dependent_three = TheoryDependent.new(
      StringToTheory.run("if((var2[var3][:params][var6] == var2[var4][:params][var6])==false)\nreturn true\nend")
    )
    mapping = {2=>IntrinsicTestCases.new,3=>Literal.new(0),6=>0.to_literal,4=>1.to_literal}
    assert_equal(
      "if((<test_cases>[0][:params][0] == <test_cases>[1][:params][0]) == false)\n\treturn true\nend\n",
      dependent_three.map_to(mapping).describe
    )
  end

end