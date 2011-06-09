require 'required'
require 'test/unit'

class TestTheoryResult < Test::Unit::TestCase
  include ContainsTheories
  
  def setup
    
  end
  
  def teardown
    System.reset
    RuntimeMethod.reset_global_id    
  end
  
  def test_intialize_1
#    assert_equal(
#      "if(<runtime_method>.all_pass?(<test_cases>))\nreturn true\nend",
#      TheoryResult.new(Parser.run("if(runtime_method.all_pass?(test_cases))\nreturn true\nend")).describe
#    )
  end
  
  def test_intialize_3
     assert_equal(
      "if(#{TheoryVariable.variable_colour(1)}var1#{TheoryVariable::NORMAL}.length == #{TheoryVariable.variable_colour(2)}var2#{TheoryVariable::NORMAL})\n\treturn true\nend\n",
      TheoryResult.new(
        StringToTheory.run("if(var1.length == var2)\n\treturn true\nend")
      ).describe
     )
  end
  
  def test_validates_2

    implementation = load_theory_implementation(2)
    
    # TODO  Should have the runtime method as a fixture so this evaluation isn't necessary
    runtime_method = RuntimeMethod.new(MethodUsage.new(MethodParameter.new))
    test_cases = [
      {:params=>['sparky'], :output=>'sparky'.length},
      {:params=>['pip'], :output=>'pip'.length},
      {:params=>['roweIAGE'], :output=>'roweIAGE'.length},
    ]    
    evaluation_code = ''
    evaluation_code += "test_cases = #{test_cases.write}"+"\n"
    evaluation_code += "runtime_method = #{runtime_method.to_declaration.write}"+"\n"
    evaluation_code += 'runtime_method.add_statement_at(Statement.new(Return.new, runtime_method.params[0]),runtime_method.statement_id)'+"\n"
    
    evaluation_code += 'return runtime_method'+"\n"        
    result = CodeEvaluation.new.evaluate_code(evaluation_code)  
    assert(true,implementation.results.all? {|x| x.validates?(result,test_cases)})
    
  end
  
  def test_same_structure_1
    # TODO  Fixtures should include implemented TheoryResult and TheoryResults - I don't like using first
    implementation = load_theory_implementation(1)
    theory = Theory.load_theory(1)
    
    implemented_result = load_implementation_result(0)
    theory_result = theory.results.first
    
    assert_equal(
      true,
      theory_result.same_structure?(implemented_result.statement)
    )
  end
     
  def test_same_structure_4
    # TODO  Fixtures should include implemented TheoryResult and TheoryResults - I don't like using first
    theory = Theory.load_theory(4)
    
    implemented_result = load_implementation_result(0)
    theory_result = theory.results.first
    assert_equal(
      false,
      theory_result.same_structure?(implemented_result.statement)
    )    
  end
  
  def test_map_to_with_case_1_theory_1
    result_one = TheoryResult.new(StringToTheory.run(
      "if(var1.history(var2[var3][:params]).any? { |x| x.statement_id == var1.last.statement_id })\nreturn true\nend"
    ))
    mapping = {
      1=>IntrinsicRuntimeMethod.new,
      2=>IntrinsicTestCases.new,
      3=>Literal.new(0),
      4=>1.to_literal,
      6=>0.to_literal
    }
    assert_equal(
      "if(<runtime_method>.history(<test_cases>[0][:params]).any?{ |x| x.statement_id == <runtime_method>.last.statement_id} )\n\treturn true\nend\n",
      result_one.map_to(mapping).describe
    )
  end
  
  def test_map_to_with_example_1
    result = TheoryResult.new(
      StringToTheory.run("if((var1.params[var3].length == var1) == false)\nreturn true\nend")
    )
    mapping = {
      1=>IntrinsicRuntimeMethod.new,
      3=>IntrinsicLiteral.new(0)
    }
    assert_equal(
      "if((runtime_method.params[0].length == runtime_method) == false)\n\treturn true\nend",
      result.map_to(mapping).write    
    )
  end
   
end