require 'required'
require 'test/unit'

class TestTheoryChainValidator < Test::Unit::TestCase
  include ContainsTheories
  
  def setup
    super 
    # TODO  Note DRY - should match that used TestTheoryConnector
    @potential_values = [
        Parser.run('0'),
        Parser.run('test_cases'),
        Parser.run('runtime_method')
    ] 
    @connector = TheoryConnector.new(@potential_values)
  end
  
  def teardown
    System.reset
    RuntimeMethod.reset_global_id        
  end
  
  def test_build_with_a_very_simple_problem
    
    # Create the simple runtime method to be populated
    runtime_method = RuntimeMethod.new(MethodUsage.new(MethodParameter.new))
    test_cases = [
      {:params=>['sparky'], :output=>'sparky'}
    ]
    finish = Parser.run("if(runtime_method.all_pass?(test_cases))\nreturn true\nend")
    assert_nothing_raised(){
      TheoryChainValidator.new.build(
        runtime_method,
        test_cases,
        @connector.chain(runtime_method,test_cases,finish,[@theory_1]),
        @potential_values
      )
    }
    assert_equal(
      true,
      TheoryChainValidator.new.build(
        runtime_method,
        test_cases,
        @connector.chain(runtime_method,test_cases,finish,[@theory_1]),
        @potential_values
      ).kind_of?(RuntimeMethod)
    )    
  end  
  
  def test_build_with_a_marginally_more_complicated_problem
    
    # Create the simple runtime method to be populated
    runtime_method = RuntimeMethod.new(MethodUsage.new(MethodParameter.new))
    test_cases = [
      {:params=>['sparky'], :output=>6}
    ]
    finish = Parser.run("if(runtime_method.all_pass?(test_cases))\nreturn true\nend")      
    assert_nothing_raised(){
      TheoryChainValidator.new.build(
        runtime_method,
        test_cases,
        @connector.chain(runtime_method,test_cases,finish,[@theory_3]),
        @potential_values
      )
    }    
    assert_equal(
      true,
      TheoryChainValidator.new.build(
        runtime_method,
        test_cases,
        @connector.chain(runtime_method,test_cases,finish,[@theory_3]),
        @potential_values).kind_of?(RuntimeMethod)
      )
    
  end
  
  def test_build_with_more_than_one_test_case
    
    # Create the simple runtime method to be populated
    runtime_method = RuntimeMethod.new(MethodUsage.new(MethodParameter.new))
    test_cases = [
      {:params=>['sparky'], :output=>'sparky'},
      {:params=>['pip'], :output=>'pip'},
      {:params=>['roweIAGE'], :output=>'roweIAGE'},
    ]
    finish = Parser.run("if(runtime_method.all_pass?(test_cases))\nreturn true\nend") 
    
    assert_nothing_raised(){
      TheoryChainValidator.new.build(
        runtime_method,
        test_cases,
        @connector.chain(runtime_method,test_cases,finish,[@theory_1]),
        @potential_values
      )
    }    
    assert_equal(
      true,
      TheoryChainValidator.new.build(
        runtime_method,
        test_cases,
        @connector.chain(runtime_method,test_cases,finish,[@theory_1]),
        @potential_values
      ).kind_of?(RuntimeMethod)
    )    
    
  end
  
  def test_build_with_more_than_one_theory
    
    # Create the simple runtime method to be populated
    runtime_method = RuntimeMethod.new(MethodUsage.new(MethodParameter.new))
    test_cases = [
      {:params=>['sparky'], :output=>'sparky'.length},
      {:params=>['pip'], :output=>'pip'.length},
      {:params=>['roweIAGE'], :output=>'roweIAGE'.length},
    ]
    finish = Parser.run("if(runtime_method.all_pass?(test_cases))\nreturn true\nend") 

    theory_7 = Theory.load_theory(7)
    theory_5 = Theory.load_theory(5)
    
    potential_values = [
        Parser.run('0'),
        Parser.run('test_cases'),
        Parser.run('runtime_method')
    ] 
    connector = TheoryConnector.new(potential_values)
    
    
    chains = connector.chain(runtime_method,test_cases,finish,[theory_7,theory_5])
    assert_equal(1,chains.length)

    assert_equal(
      true,
      TheoryChainValidator.new.build(
        runtime_method,
        test_cases,
        chains,
        potential_values
      ).kind_of?(RuntimeMethod)
    )    
    # TODO  Should include specfic implementation chain that works and one that doesn't
    #       for better testing.
    
  end    
  
  def test_build_with_two_params

    # Create the simple runtime method to be populated
    runtime_method = RuntimeMethod.new(MethodUsage.new(MethodParameter.new,MethodParameter.new))
    test_cases = [
      {:params=>['left 4',' dead'], :output=>'left 4 dead'}
    ]
    finish = Parser.run("if(runtime_method.all_pass?(test_cases))\nreturn true\nend")    
    theory_8 = Theory.load_theory(8)
    
    # TODO  I'll need to start generating the potential values based on the particular test cases
    potential_values = [
        Parser.run('0'),
        Parser.run('1'),
        Parser.run('test_cases'),
        Parser.run('runtime_method')
    ]     
    
    connector = TheoryConnector.new(potential_values)
    chains = connector.chain(runtime_method,test_cases,finish,[theory_8])
    assert_equal(
      true,
      TheoryChainValidator.new.build(
        runtime_method,
        test_cases,
        chains,
        potential_values
      ).kind_of?(RuntimeMethod)
    )
    # Action Needed: 
    #
    #    runtime_method.add_statement_at(
    #      Statement.new(Unknown.new,Equal.new,runtime_method.params[0],Addition.new,runtime_method.params[1]),
    #      0
    #    ) 
    #   or

    # Action statement needs to write - theory Statement
    # Statement.new(Unknow.new,var1,Addition.new,var2)
    #
    # or
    #
    # StringToTheory.run('Statement.new(Unknown.new,var1,Addition.new,var2)')
    # where var1 and var2 are theory variables that are substituted
    
    # So the statement
    #   a = StringToTheory.run('Parser.run("var = var1 + var2")')
    #   where var1 and var2 are the theory variables
    #
    #   they get substituted say var1 = runtime_method.params[0] and var2 = runtime_method.params[2]

    #   So the implementation is 
    #
    #   'Parser.run("var = runtime_method.params[0] + runtime_method.params[2]")'
    # TODO  For clarity I should distingish in syntax between theory variables and
    #       regular variables e.g. x1 and y1. 

    
  end
  
  def test_build_with_case_1
    theory_1 = Theory.load_theory(13) 
    theory_2 = Theory.load_theory(14)
    theory_3 = Theory.load_theory(15)
    theory_4 = Theory.load_theory(12)
    
    runtime_method = RuntimeMethod.new(MethodUsage.new(MethodParameter.new))
    test_case_1 = CTestCase.new 
    test_case_1[:params] = ['something']
    test_case_1[:output] = 'exists'
    test_case_2 = CTestCase.new
    test_case_2[:params] = ['my willpower']
    test_case_2[:output] = 'does not exist'
    test_cases = [
      test_case_1,test_case_2
    ]
    
    tc = Parser.run('test_cases')
    tc_index_0 = IntrinsicLiteral.new(0)
    tc_index_1 = IntrinsicLiteral.new(1)
    param_0 = IntrinsicLiteral.new(0)
    real_method = Parser.run('runtime_method') 
    last_real_method = Parser.run('last_runtime_method')    
    
    finish = OpenStatement.new(
      Statement.new(If.new,Container.new(InstanceCallContainer.new(real_method,AllPass.new,tc)))
    )
    finish << Statement.new(Return.new,True.new)
    potential_values = MappingValues.new([tc,tc_index_0,tc_index_1,param_0,real_method,last_real_method])  

    connector = TheoryConnector.new(potential_values)
    chains = connector.chain(runtime_method,test_cases,finish,[theory_1,theory_2,theory_3,theory_4])
    
    assert_equal(
      true,
      TheoryChainValidator.new.build(
        runtime_method,
        test_cases,
        chains,
        potential_values
      ).kind_of?(RuntimeMethod)
    ) 
  end  
  
  def test_build_method_from_chain
    theory_1 = Theory.load_theory(16)
    theory_2 = Theory.load_theory(17)
    theory_3 = Theory.load_theory(18)
    
    # [:params = [‘Belfast’], ‘result’ = ‘B’]
    test_case_1 = CTestCase.new 
    test_case_1[:params] = ['Belfast']
    test_case_1[:output] = 'B'
    test_cases = [
      test_case_1
    ]
    tc = Parser.run('test_cases')
    tc_index_0 = IntrinsicLiteral.new(0)
    real_method = Parser.run('runtime_method')
    
    finish = OpenStatement.new(
      Statement.new(If.new,Container.new(InstanceCallContainer.new(real_method,Pass.new,ArrayAccess.new(tc,tc_index_0))))
    )
    finish << Statement.new(Return.new,True.new)
    potential_values = MappingValues.new([
        tc,
        real_method,
        tc_index_0,
        IntrinsicLiteral.new(0),
        Parser.run('last_runtime_method')
    ])         
    runtime_method = RuntimeMethod.new(MethodUsage.new(MethodParameter.new))
    
    connector = TheoryConnector.new(potential_values)
    chains = connector.chain(runtime_method,test_cases,finish,[theory_1,theory_2,theory_3])
    chains.each do |x|
      assert_nothing_raised(){TheoryChainValidator.new.build_method_from_chain(x,runtime_method,test_cases)}
    end
    
    assert_equal(
      true,
      TheoryChainValidator.new.build_method_from_chain(chains[1],runtime_method,test_cases).kind_of?(RuntimeMethod)
    )
    
  end
  
  def test_build_with_chop_chop

#     TODO  Uncomment this  - it should be available
    
#    theory_1 = Theory.load_theory(16)
#    theory_2 = Theory.load_theory(17)
#    theory_3 = Theory.load_theory(18)    
#    
#    # [:params = [‘Belfast’], ‘result’ = ‘B’]
#    test_case_1 = CTestCase.new 
#    test_case_1[:params] = ['Belfast']
#    test_case_1[:output] = 'B'
#    test_cases = [
#      test_case_1
#    ]
#    tc = Parser.run('test_cases')
#    tc_index_0 = IntrinsicLiteral.new(0)
#    real_method = Parser.run('runtime_method')
#    
#    finish = OpenStatement.new(
#      Statement.new(If.new,Container.new(InstanceCallContainer.new(real_method,Pass.new,ArrayAccess.new(tc,tc_index_0))))
#    )
#    finish << Statement.new(Return.new,True.new)
#    potential_values = MappingValues.new([
#        tc,
#        real_method,
#        tc_index_0,
#        IntrinsicLiteral.new(0),
#        Parser.run('last_runtime_method')
#    ])         
#    runtime_method = RuntimeMethod.new(MethodUsage.new(MethodParameter.new))
#    
#    connector = TheoryConnector.new(potential_values)
#    chains = connector.chain(runtime_method,test_cases,finish,[theory_1,theory_2,theory_3])
#    assert_equal(
#      true,
#      TheoryChainValidator.new.build(
#        runtime_method,
#        test_cases,
#        chains,
#        potential_values
#      ).kind_of?(RuntimeMethod)
#    )     
    
  end  
  
  
end