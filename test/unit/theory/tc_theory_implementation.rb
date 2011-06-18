$LOAD_PATH << File.expand_path('../../../../lib',__FILE__)

require 'cauldron'


require 'test/unit'
 
class TestTheoryImplementation < Test::Unit::TestCase
  include ContainsTheories  
  
  def setup
    super
    
    demo_1_test_case_1 = CTestCase.new 
    demo_1_test_case_1[:params] = ['sparky']
    demo_1_test_case_1[:output] = 'sparky'
    demo_1_test_case_2 = CTestCase.new
    demo_1_test_case_2[:params] = ['kel']
    demo_1_test_case_2[:output] = 'kel'
    @case_1_test_cases = [
      demo_1_test_case_1,demo_1_test_case_2
    ]    
    @case_1_runtime_method = RuntimeMethod.new(MethodUsage.new(MethodParameter.new))
    
  end
  
  def teardown
    System.reset
    RuntimeMethod.reset_global_id        
  end
  
  def test_leads_to
    
    # TODO  I need a better way to rebuild the implementations - I need to be able to save the declaration probably
    #       It could grep the desc.txt for those in the theory - I need to be able to rebuild them.
   implementation_0 = load_theory_implementation(0)
    finish = Parser.run("if(runtime_method.all_pass?(test_cases))\nreturn true\nend")
    assert_equal(
      true,
      implementation_0.leads_to?(finish)
    )
  end
  
  def test_copy
    implementation_0 = load_theory_implementation(0)
    assert_equal(
      implementation_0.describe,
      implementation_0.copy.describe
    )
  end
    
  # Test the creation of a very simple theory action that just adds a 
  # return statement to the runtime method.
  #
  def test_theory_three_implementations
    # TODO  Need to raise error if number of values available doesn't meet
    #       the theory.  This just doesn't return an permutations if you only
    #       supply.
    # TODO  Also need a quick check that all the theories are included in the test suite 
    values = [
      Parser.run('runtime_method'),
      Parser.run('test_cases'),
      Parser.run('0')
    ]
    assert_nothing_raised(){@theory_3.rewrite_permutations(values)}
    assert_equal(6,@theory_3.rewrite_permutations(values).length)
    
    #first_imlementation = @theory_3.rewrite_permutations(values).first
    #  if: 
    #    if(runtime_method.params[0].value.length == test_cases[0][:output])
    #    end
    #  action: 
    #    <runtime_method>.add_statement_at(Statement.new(Return.new(), InstanceCallContainer.new(runtime_method.params[0], StringLength.new())),0)
    #  result: 
    #    runtime_method.all_pass?(test_cases) = true
    runtime_method = RuntimeMethod.new(MethodUsage.new(MethodParameter.new))
    test_cases = [
      {:params=>['sparky'], :output=>6}
    ]
    first_imlementation = @theory_3.rewrite_permutations(values).first
    assert_equal(true,first_imlementation.meets_dependencies?(runtime_method.copy,test_cases))
    
    test_cases = [
      {:params=>['pip'], :output=>3}
    ]
    first_imlementation = @theory_3.rewrite_permutations(values).first
    assert_equal(true,first_imlementation.meets_dependencies?(runtime_method.copy,test_cases))
     
    # NOTE: Although the theory is strickly speaking wrong here because it only uses the 
    #       first paramter - this fine here though because this method only checks the 
    #       dependencies are met. 
    test_cases = [
      {:params=>['sparky'], :output=>6},
      {:params=>['pip'], :output=>3},
    ]    
    first_imlementation = @theory_3.rewrite_permutations(values).first
    assert_equal(true,first_imlementation.meets_dependencies?(runtime_method.copy,test_cases))
      
  end
  
  def test_meets_dependencies__with_theory_17
#     #TODO  Uncomment this - it is a valid test    
#    theory = Theory.load_theory(17)
#    
#    # Create the runtime method and test cases that should pass the theories dependents
#    test_case_1 = CTestCase.new 
#    test_case_1[:params] = ['waz']
#    test_case_1[:output] = 'B'
#    test_cases = [
#      test_case_1
#    ]
#    runtime_method = RuntimeMethod.new(MethodUsage.new(MethodParameter.new))
#    
#    # Create the mapping for the theory
#    m = Mapping.new(
#      {
#        1=>IntrinsicRuntimeMethod.new,
#        2=>IntrinsicLiteral.new(0),
#        3=>IntrinsicTestCases.new,
#        4=>IntrinsicLiteral.new(0),
#        5=>Parser.run('last_runtime_method')
#      }
#    )
#    
#    # Add the statement to the runtime method to make the dependent correct
#    s = BlockStatement.new(Statement.new(InstanceCallContainer.new(Container.new(InstanceCallContainer.new(runtime_method.params[0], StringLength.new), Subtract.new, 1), Times.new)))
#    runtime_method.push(s)
#    
#    implementation = theory.map_to(m)
#    pp runtime_method.history2(test_cases[0][:params])
#    assert_equal(
#      true,
#      implementation.meets_dependencies?(runtime_method,test_cases)
#    )      
  end
  
end