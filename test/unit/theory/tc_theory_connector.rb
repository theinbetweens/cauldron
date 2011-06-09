require 'required'
require 'test/unit'

class TestTheoryConnector < Test::Unit::TestCase
  include ContainsTheories
  
  def setup
    super 
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
  
  def test_initialize
    assert_nothing_raised(){TheoryConnector.new(@potential_values)}   
  end
  
  def test_chain_with_a_easy_problem_and_only_one_theory
    
    # Create the simple runtime method to be populated
    runtime_method = RuntimeMethod.new(MethodUsage.new(MethodParameter.new))
    sparky = CTestCase.new
    sparky[:params] = ['sparky']
    sparky[:output] = 'sparky'
    pip = CTestCase.new
    pip[:params] = ['pip']
    pip[:output] = 'pip'
    test_cases = [
      sparky,pip
    ]
    finish = Parser.run("if(runtime_method.all_pass?(test_cases))\nreturn true\nend")
     
    # NOTE: To solve this it just needs to include an action that returns the first variable
    # Create the VERY simple theory to solve this.
    theory_action = TheoryAction.new(
      TheoryStatement.new(StringToTheory.run('Statement.new(Return.new,var1.params[0])')),
      StringToTheory.run('var1.statement_id')
    )
    result_one = TheoryResult.new(
      StringToTheory.run("if(var1.all_pass?(var2))\nreturn true\nend")
    )    
    solution_theory = Theory.new([],theory_action,[result_one])
    assert(@connector.chain(runtime_method,test_cases,finish,[solution_theory]).kind_of?(Array))
    assert_equal(1,@connector.chain(runtime_method,test_cases,finish,[solution_theory]).length)
    assert(@connector.chain(runtime_method,test_cases,finish,[solution_theory]).all? {|x| x.kind_of?(Chain)})
    assert(@connector.chain(runtime_method,test_cases,finish,[solution_theory]).all? {|x| x.length == 2})
    
    # Check that the generated chain works    
    implemented = @connector.chain(runtime_method,test_cases,finish,[solution_theory]).first.implement
    result = TheoryChainValidator.new.build(
      runtime_method,
      test_cases,
      [implemented],
      []
    )
    assert_equal(
      true,
      result.kind_of?(RuntimeMethod)
    )
        
  end
  
  def test_create_possible_chain_extensions_with_a_very_simple_problem
     
    directory_path = $LOC+File.join('test','fixtures','chains','1')
    raise StandardError.new("chain 1 does not exist") unless(File.exists?(directory_path))
    dump_file = File.open(File.join(directory_path,'dump'),'r')
         
    initial_chain = Marshal.load(dump_file)     
    theory_6 = Theory.load_theory(6)
     
    # Create the simple runtime method to be populated
    runtime_method = RuntimeMethod.new(MethodUsage.new(MethodParameter.new))
    sparky = CTestCase.new
    sparky[:params] = ['sparky']
    sparky[:output] = 'sparky'
    pip = CTestCase.new
    pip[:params] = ['pip']
    pip[:output] = 'pip'
    test_cases = [
      sparky,pip
    ]
    finish = Parser.run("if(runtime_method.all_pass?(test_cases))\nreturn true\nend")
    
    # TEMPORARY Hack remove all the results that don't resemble at least one of the theories
    # dependents.
    theory_dependents = [theory_6].inject([]) {|total,x| total += x.dependents}
    new_results = []
    initial_chain.first.results.each do |r|
      if theory_dependents.any? {|x| r.same_structure?(x)}
        new_results.push(r)
      end
    end
    assert_equal(
      1,
      @connector.create_possible_chain_extensions(runtime_method,test_cases,finish,[theory_6],initial_chain).length
    )   
    assert_equal(
      true,
      @connector.chain(runtime_method,test_cases,finish,[theory_6]).all? {|x| x.kind_of?(Chain)}
    )
    
  end
  
  def test_chain_with_a_marginally_more_complicated_problem
    
    # Create the simple runtime method to be populated
    runtime_method = RuntimeMethod.new(MethodUsage.new(MethodParameter.new))
    test_cases = [
      {:params=>['sparky'], :output=>3},
      {:params=>['pip'], :output=>3},
    ]
    finish = Parser.run("if(runtime_method.all_pass?(test_cases))\nreturn true\nend") 
    assert_equal(
      true,
      @connector.chain(runtime_method,test_cases,finish,[@theory_3]).kind_of?(Array)
    )      
    assert_equal(
      true,
      @connector.chain(runtime_method,test_cases,finish,[@theory_3]).all? {|x| x.all? {|y| y.kind_of?(Theory)}}
    )   
    
  end  
  
  def test_chain_with_addition_theory

    runtime_method = RuntimeMethod.new(MethodUsage.new(MethodParameter.new,MethodParameter.new))
    test_cases = [
      {:params=>['left 4','dead'], :output=>'left 4 dead'}
    ]    
    finish = Parser.run("if(runtime_method.all_pass?(test_cases))\nend")
    
  end
  
  def test_chain_with_2_theories

    runtime_method = RuntimeMethod.new(MethodUsage.new(MethodParameter.new))
    sparky = CTestCase.new
    sparky[:params] = ['sparky']
    sparky[:output] = 6
    kel = CTestCase.new
    kel[:params] = ['kel']
    kel[:output] = 3
    test_cases = [
      sparky,kel
    ]    
    finish = Parser.run("if(runtime_method.all_pass?(test_cases))\nreturn true\nend")
    theory_7 = Theory.load_theory(7)
    theory_5 = Theory.load_theory(5)
    
    directory_path = $LOC+File.join('test','fixtures','chains','2')
    raise StandardError.new("chain 2 does not exist") unless(File.exists?(directory_path))
    dump_file = File.open(File.join(directory_path,'dump'),'r')    
    initial_chain = Marshal.load(dump_file)         

    # Temporary Hack remove all the results that don't resemble at least one of the theories
    # dependents.
    theory_dependents = [theory_7,theory_5].inject([]) {|total,x| total += x.dependents}
    new_results = []
    initial_chain.first.results.each do |r|
      if theory_dependents.any? {|x| r.same_structure?(x)}
        new_results.push(r)
      end
    end
    #initial_chain.first.results = new_results
    initial_chain.first.results = [new_results[0]]
    
    
    #exit
    # TEMP - Removing most of the dependents
#    initial_chain.first.results.each_with_index do |x,i|
#      #if x.write.include?('if(var1.realise2(var2[var3][:params]).params[var4].value.length == var2[var3][:output])')
#      if x.write.include?('if(var1.realise2(var2[var3][:params]).params[var8].value.length == var2[var3][:output])')        
#      end
#    end
#    exit
    #initial_chain.first.results = initial_chain.first.results = [initial_chain.first.results[429]]
    #initial_chain.first.results = initial_chain.first.results[0..1]
    #if(var1.realise2(var2[var3][:params]).params[var4].value.length == var2[var3][:output])
    

#    # Quicker version thath uses pre-generated head
#    assert_equal(
#      true,
#      @connector.create_possible_chain_extensions(
#        runtime_method,
#        test_cases,
#        finish,
#        [theory_4,theory_5],
#        initial_chain
#      ).kind_of?(Array)
#    ) 

#    assert_equal(
#      true,
#      @connector.chain(runtime_method,test_cases,finish,[theory_4,theory_5]).kind_of?(Array)
#    )

#    assert_equal(
#      true,
#      @connector.chain(runtime_method,test_cases,finish,[@theory_3]).all? do |x| 
#        x.all? {|y| y.kind_of?(Theory)}
#      end
#    ) 
#    assert_equal(
#      true,
#      @connector.chain(runtime_method,test_cases,finish,[theory_4,theory_5]).all? do |x| 
#        x.all? {|y| y.kind_of?(Theory)}
#      end
#    )    
#    assert(@connector.chain(runtime_method,test_cases,finish,[theory_4,theory_5]).length > 0)
#    

    assert_equal(
      true,
      @connector.create_possible_chain_extensions(
        runtime_method,
        test_cases,
        finish,
        [theory_7,theory_5],
        initial_chain
      ).any? {|x| x.length > 1 }
     )
    
  end
  
  def test_with_case_1
    theory_1 = Theory.load_theory(20) 
    # TODO  Do I really want theories with out actions I should maybe move the result 
    #       for theory_4 to theory 3. - UPDATE I'm pretty sure I need theories with out
    #       actions need to confirm.
    theory_2 = Theory.load_theory(14)
    theory_3 = Theory.load_theory(15)
    theory_4 = Theory.load_theory(12)
    
    # Create the initial starting chain from pre-existing chain
    directory_path = $LOC+File.join('test','fixtures','chains','3')
    raise StandardError.new("chain 3 does not exist") unless(File.exists?(directory_path))
    dump_file = File.open(File.join(directory_path,'dump'),'r')    
    initial_chain = Marshal.load(dump_file)       
    
    # Create the empty runtime method and test cases
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
    finish = Parser.run("if(runtime_method.all_pass?(test_cases))\nreturn true\nend")
    
    initial_chain.remove_superfluous_head_results!([theory_1,theory_2,theory_3,theory_4])
    
    # Check that at least one complete chain is created
    assert_equal(
      true,
      @connector.create_possible_chain_extensions(
        runtime_method,
        test_cases,
        finish,
        [theory_1,theory_2,theory_3,theory_4],
        initial_chain
      ).any? {|x| x.length > 1 }
     )    
    
    
#    runtime_method = RuntimeMethod.new(MethodUsage.new(MethodParameter.new))
#    test_case_1 = CTestCase.new 
#    test_case_1[:params] = ['something']
#    test_case_1[:output] = 'exists'
#    test_case_2 = CTestCase.new
#    test_case_2[:params] = ['my willpower']
#    test_case_2[:output] = 'does not exist'
#    test_cases = [
#      test_case_1,test_case_2
#    ]
#    
#    tc = Parser.run('test_cases')
#    tc_index_0 = IntrinsicLiteral.new(0)
#    tc_index_1 = IntrinsicLiteral.new(1)
#    param_0 = IntrinsicLiteral.new(0)
#    real_method = Parser.run('runtime_method') 
#    last_real_method = Parser.run('last_runtime_method')
#    
#    finish = OpenStatement.new(
#      IfContainer.new(InstanceCallContainer.new(real_method,AllPass.new,tc))
#    )
#    finish << Statement.new(Return.new,True.new)
#    potential_values = MappingValues.new([tc,tc_index_0,tc_index_1,param_0,real_method,last_real_method])     
#    connector = TheoryConnector.new(potential_values)
#    assert_equal(
#      36,
#      connector.chain(runtime_method,test_cases,finish,[theory_1,theory_2,theory_3,theory_4]).length
#    )
      
#    # DEVELOPMENT - Output each chain to a file
#    res = connector.chain(runtime_method,test_cases,finish,[theory_1,theory_2,theory_3,theory_4])
#    res.each_with_index do |x,i|
#    end
      
  end
  
  def test_unify_chain_with_a_very_simple_problem
    
    runtime_method = RuntimeMethod.new(MethodUsage.new(MethodParameter.new))
    test_cases = [
      {:params=>['sparky'], :output=>6},
      {:params=>['kel'], :output=>3}
    ]
    finish = Parser.run("if(runtime_method.all_pass?(test_cases))\nreturn true\nend")
    
    theory_4 = Theory.load_theory(4)
    theory_5 = Theory.load_theory(5)
    
    # Update the theries so their variables don't match to start
    theory_4 = theory_4.map_to(Mapping.new({1=>TheoryVariable.new(8),2=>TheoryVariable.new(9),3=>TheoryVariable.new(10)}))
    theory_5 = theory_5.map_to(Mapping.new({1=>TheoryVariable.new(109),2=>TheoryVariable.new(85),3=>TheoryVariable.new(23)}))
    
    assert_equal(
      Array,
      TheoryConnector.new([]).unify_chain([theory_4,theory_5]).class
    )
    assert_equal(
      1,
      TheoryConnector.new([]).unify_chain([theory_4,theory_5].reverse).length
    )
    TheoryConnector.new([]).unify_chain([theory_4,theory_5].reverse).each do |chain|
      chain.each do |theory|
      end
    end
    TheoryConnector.new([]).unify_chain([theory_4,theory_5].reverse).each do |chain|
      assert_equal(
        2,
        chain.length
      )
    end
    TheoryConnector.new([]).unify_chain([theory_4,theory_5].reverse).each do |chain|
      assert_equal(
        3,
        chain.uniq_theory_variable_ids.length
      )
    end    
    
  end
  
  
  def test_chain_with_chop_chop
    
    theory_1 = Theory.load_theory(16)
    theory_2 = Theory.load_theory(17)
    theory_3 = Theory.load_theory(18)    
    #finish = Parser.run("if(runtime_method.pass?(test_cases[0]))\nreturn true\nend")
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
      IfContainer.new(InstanceCallContainer.new(real_method,Pass.new,ArrayAccess.new(tc,tc_index_0)))
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
    assert_equal(
      2,
      connector.chain(runtime_method,test_cases,finish,[theory_1,theory_2,theory_3]).length
    )
    
  end
  
end