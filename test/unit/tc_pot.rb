require 'required'
require 'test/unit'

class TestInstanceCallStructure < Test::Unit::TestCase
  
  def setup
    @cauldron = Cauldron::Pot.new()
    
    # Create demonstration #1
    # (just return the first parameter)
    demo_1_test_case_1 = CTestCase.new 
    demo_1_test_case_1[:params] = ['sparky']
    demo_1_test_case_1[:output] = 'sparky'
    demo_1_test_case_2 = CTestCase.new
    demo_1_test_case_2[:params] = ['kel']
    demo_1_test_case_2[:output] = 'kel'
    @demo_1_test_cases = [
      demo_1_test_case_1,demo_1_test_case_2
    ]
    
    # Create demonstration #2
    demo_2_test_case_1 = CTestCase.new 
    demo_2_test_case_1[:params] = ['something']
    demo_2_test_case_1[:output] = 'exists'
    demo_2_test_case_2 = CTestCase.new
    demo_2_test_case_2[:params] = ['my willpower']
    demo_2_test_case_2[:output] = 'does not exist'
    demo_2_test_cases = [
      demo_2_test_case_1,demo_2_test_case_2
    ] 
    
    # Create demo #1 chain
    #   Create the head for the chain
    head = Theory.new([],nil,[])    
    
    link_one_action = TheoryAction.new(
      TheoryStatement.new(StringToTheory.run('Statement.new(Return.new,var2.params[var3])')),
      StringToTheory.run('var1.statement_id')
    )
    # NOTE: I need to add one result so the theory can be flagged as complete - I might not need it 
    #       to be complete -
    link_one_result = TheoryResult.new(StringToTheory.run("if(var1.all_pass?(var2))\nreturn true\nend"))
    link_one = Theory.new([],link_one_action,[link_one_result])
    chain = Chain.new
    chain = chain.add_link(head).first
    chain = chain.add_link(
      link_one,
      {
        1=>IntrinsicRuntimeMethod.new,
        2=>IntrinsicTestCases.new,
        3=>IntrinsicLiteral.new(0)
      }
    ).first
    
    # Now implement the chain
    implemented_chain = chain.implement
    
    # TODO  It should generate the values too.(TheoryGenerator)
    @demo_1 = {
      :initial_method=>RuntimeMethod.new(MethodUsage.new(MethodParameter.new)),
      :test_cases=>@demo_1_test_cases,
      :chain=>chain,
      :values=>{}
    }
#    action = TheoryAction.new(
#      TheoryStatement.new(StringToTheory.run('Statement.new(Return.new,var2[var4][:output])')),
#      StringToTheory.run('var5.statement_id')
#    )          
    
  end
  
  def teardown
    System.reset
    RuntimeMethod.reset_global_id
  end  

  def test_with_simple_test_case
    
    test_case_1 = CTestCase.new 
    test_case_1[:params] = ['something']
    test_case_1[:output] = 'exists'
    test_case_2 = CTestCase.new
    test_case_2[:params] = ['my willpower']
    test_case_2[:output] = 'does not exist'
    test_cases = [
      test_case_1,test_case_2
    ]    
     
    #assert_nothing_raised() {@cauldron.brew(test_cases)}           
  end

  # Checks that a theory is created for a very simple 
  # example that just requires adding a single statement
  # to a runtime method.
  #
  def test_simmer_with_very_basic_theory
    
    @cauldron.clear
    # TEMP Notes
    # 1.  Confirm that the chain solves the problem
    # 2.  Generate a master theory for each of the steps
    # 3.  Add each of simple theories to the bank.
    # 4.  Need to clear the cauldron after each generation(for testing) 
    assert_nothing_raised(){@cauldron.simmer(@demo_1)}
    
  end
  
  def test_brew_with_case_1
    
    # => TODO Should clear, then simmer first
    assert_nothing_raised(){@cauldron.brew(@demo_1_test_cases)}
    
    assert_equal(true,@cauldron.brew(@demo_1_test_cases).kind_of?(RuntimeMethod))
  end
  
  def test_demo_works_with_demo_1
    assert_equal(true,@cauldron.demo_works?(@demo_1))
  end
  
  def test_clear
    assert_nothing_raised(){@cauldron.clear}
  end

end