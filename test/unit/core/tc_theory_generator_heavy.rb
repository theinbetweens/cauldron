require 'required'
require 'test/unit'

class TestTheoryGenerator < Test::Unit::TestCase
  
  def setup

    test_case_1 = CTestCase.new 
    test_case_1[:params] = ['something']
    test_case_1[:output] = 'exists'
    test_case_2 = CTestCase.new
    test_case_2[:params] = ['my willpower']
    test_case_2[:output] = 'does not exist'
    @set_1_test_cases = [
      test_case_1,test_case_2
    ]
    @runtime_method = RuntimeMethod.new(MethodUsage.new(MethodParameter.new))    
    
  end
  
  def teardown
    System.reset
    RuntimeMethod.reset_global_id
  end  
  
  # Checks that the first statement "if(var == 'my willpower')" can be generated
  # 
  # test time: 37mins
  #
  def test_generate_theories_with_case_1_statement_1
    
    accessors, mapping = TheoryGenerator.new.generate_accessors_and_mapping(@set_1_test_cases,@runtime_method,3)
    theories = TheoryGenerator.new.generate_theories(@set_1_test_cases,@runtime_method,accessors,mapping)    
    assert_equal(
      true,
      theories.any? do |x|
        x.write == '<runtime_method>.add_statement_at(OpenStatement.new(IfContainer.new(var1.params[var5], Equivalent.new, var2[var3][:params][var5])),var1.statement_id)'
      end
    )
  end
      
end