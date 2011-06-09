require 'required'
require 'test/unit'

class TestChain < Test::Unit::TestCase
  include ContainsTheories  
  
  def setup
    
  end
  
  def teardown
    System.reset
    RuntimeMethod.reset_global_id
  end  
  
  # Create the most simple of chains that only has a head and a tail and completes
  def test_initialize_1
    
    # Create the single requirement
    result_one = TheoryResult.new(StringToTheory.run("if(var1.all_pass?(var2))\nreturn true\nend"))
    head = Theory.new([],nil,[result_one])    
    
    # Check initial declaration 
    assert_nothing_raised(){Chain.new()}
    
    # Add the head to the chain - completing it
    chain = Chain.new()
    assert_nothing_raised(){chain.add_link(head)}
    chain_results = chain.add_link(head)
    assert_equal(true,chain_results.any? {|x|x.complete?})
    
    # Implement the chain
    assert_equal(1,chain_results.length)
    complete_chain = chain_results.first
    assert_nothing_raised() {complete_chain.implement}
    
  end
  
  # Test a very simple chain that shares all the save variable ids(negating the mapping) but is made up
  # of a head, link and tail.
  def test_initialize_2
    
    # Create the head for the chain
    head_result = TheoryResult.new(StringToTheory.run("if(var2[var3][:output]==var2[var3][:params][var4])\nreturn true\nend"))
    head = Theory.new([],nil,[head_result]) 
      
    # Create linking method
    link_one_dependent_one = TheoryDependent.new(StringToTheory.run("if(var2[var3][:output]==var2[var3][:params][var4])\nreturn true\nend"))
    link_one_action = TheoryAction.new(
      TheoryStatement.new(StringToTheory.run('Statement.new(Return.new,var2[var3][:output])')),
      StringToTheory.run('var1.statement_id')
    )
    link_one_result = TheoryResult.new(StringToTheory.run("if(var1.all_pass?(var2))\nreturn true\nend"))
    link_one = Theory.new([link_one_dependent_one],link_one_action,[link_one_result])
    
    # Create the initial chain and confirm it isn't complete (the head can't connect to tail)
    chain = Chain.new
    assert_equal(false,chain.complete?)
    
    assert_nothing_raised(){chain.add_link(head)}
    chain_results = chain.add_link(head)
    
    # Add the next chain in the link
    extended_results = []
    chain_results.each do |c|
      extended_results += c.add_link(link_one)
    end
    chain_results = extended_results    
    
    assert_equal(true,chain_results.all? {|x| x.kind_of?(Chain)})
    assert_equal(true,chain_results.all? {|x| x.complete? })
    assert_equal(true,chain_results.all? {|x| x.broken_link_count == 0})
    
  end
  
  # Test that this very simple chain can be unified
  # 
  def test_unifiy_chain_1
    head = Theory.new([],nil,[])    
    
    link_one_action = TheoryAction.new(
      TheoryStatement.new(StringToTheory.run('Statement.new(Return.new,var2[var3][:output])')),
      StringToTheory.run('var1.statement_id')
    )
    link_one_result = TheoryResult.new(StringToTheory.run("if(var1.all_pass?(var2))\nreturn true\nend"))
    link_one = Theory.new([],link_one_action,[link_one_result])
    chain = Chain.new
    chain = chain.add_link(head).first
    chain = chain.add_link(link_one).first
    
    global_ids = chain.chain_mapping.mapping.collect {|key,value| key}
    
    assert_equal(
      true,
      global_ids.all? do |x|
        chain.unify_chain.write.include?('var'+x.to_s)
      end
    )
    
  end
  
  # Test that an extremely basic chain can be implemented.  The chain 
  # basically involves adding one return statement to a runtime method.
  #
  def test_implement_1
    
    head = Theory.new([],nil,[])    
    
    link_one_action = TheoryAction.new(
      TheoryStatement.new(StringToTheory.run('Statement.new(Return.new,var2[var3][:output])')),
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
    
    # Attempt to implement the chain
    assert_nothing_raised() {chain.implement}
    implemented_chain = chain.implement
    assert_equal(false,implemented_chain.write.include?('var'))
    
  end
  
  # Checks that a implemented theory can be created with the very basic
  # chain.
  #
  def test_theory_progression_with_case_1
    
    # ----------------- SETUP -----------------
    # Create demonstration #1
    # (just return the first parameter)
    demo_1_test_case_1 = CTestCase.new 
    demo_1_test_case_1[:params] = ['sparky']
    demo_1_test_case_1[:output] = 'sparky'
    demo_1_test_case_2 = CTestCase.new
    demo_1_test_case_2[:params] = ['kel']
    demo_1_test_case_2[:output] = 'kel'
    demo_1_test_cases = [
      demo_1_test_case_1,demo_1_test_case_2
    ]    
    
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
    runtime_method = RuntimeMethod.new(MethodUsage.new(MethodParameter.new))
    
    # ---------------- Attempt to create the three theory snapshots -------------
    assert_nothing_raised() {chain.theory_progression(runtime_method,demo_1_test_cases)}
    assert_equal(3,chain.theory_progression(runtime_method,demo_1_test_cases).length)
    assert_equal(true,chain.theory_progression(runtime_method,demo_1_test_cases).all?{|x| x.kind_of?(TheoryImplementation)})
    
  end
  
  # Test implementation with the simple example that just returns the passed
  # value.
  def test_implement_2
    
    # Create the head for the chain
    head_result = TheoryResult.new(StringToTheory.run("if(var2[var3][:output]==var2[var3][:params][var4])\nreturn true\nend"))
    head = Theory.new([],nil,[head_result]) 
      
    # Create linking method
    link_one_dependent_one = TheoryDependent.new(StringToTheory.run("if(var2[var3][:output]==var2[var3][:params][var4])\nreturn true\nend"))
    link_one_action = TheoryAction.new(
      TheoryStatement.new(StringToTheory.run('Statement.new(Return.new,var2[var3][:output])')),
      StringToTheory.run('var1.statement_id')
    )
    link_one_result = TheoryResult.new(StringToTheory.run("if(var1.all_pass?(var2))\nreturn true\nend"))
    link_one = Theory.new([link_one_dependent_one],link_one_action,[link_one_result])
    
    # Create the values for the head
    head_values = {2=>IntrinsicTestCases.new,3=>IntrinsicLiteral.new(0),4=>IntrinsicLiteral.new(0)}
    link_one_values = { 1=>IntrinsicRuntimeMethod.new,
                        2=>IntrinsicTestCases.new,
                        3=>IntrinsicLiteral.new(0),
                        4=>IntrinsicLiteral.new(0)
                      }
    
    # Create the initial chain and confirm it isn't complete (the head can't connect to tail)
    chain = Chain.new
    assert_equal(false,chain.complete?)
    
    assert_nothing_raised(){chain.add_link(head)}
    chain_results = chain.add_link(head,head_values)
    
    # Add the next chain in the link
    extended_results = []
    chain_results.each do |c|
      extended_results += c.add_link(link_one,link_one_values)
    end
    chain_results = extended_results    
    assert_equal(1,chain_results.length)
    
    # Now attempt to implement it
    complete_chain = chain_results.first
    assert_equal(true,complete_chain.complete?)
    assert_nothing_raised(){complete_chain.implement}
    
  end
  
  # Add the theories needded to create a simple 'if' runtime method
  #
  # def method_1(var1)
  #   if var1 == 'something'
  #     return 'exist'
  #   end
  #   return 'does not exists'
  # end
  #
  def test_add_link_to_3
    
    theory_1 = Theory.load_theory(20) 
    theory_2 = Theory.load_theory(14)
    theory_3 = Theory.load_theory(15)
    theory_4 = Theory.load_theory(12)
    
    # Create te head for the theory
    head_result_one = TheoryResult.new(StringToTheory.run("if(var2[var3].kind_of?(CTestCase))\nreturn true\nend"))
    head_result_two = TheoryResult.new(
      StringToTheory.run("if((var2[var3][:params][var6] == var2[var4][:params][var6])==false)\nreturn true\nend")
    )
    head = Theory.new([],nil,[head_result_one,head_result_two]) 
    
    # Create the initial chain
    chain = Chain.new
    
    # Add the head link to the chain
    chain_results = chain.add_link(head)

    # Add the next link to the chain
    extended_results = []
    chain_results.each do |c|
      extended_results += c.add_link(theory_1)
    end
    chain_results = extended_results

    assert_equal(1,chain_results.length)
    assert_equal(false,chain_results.all? {|x| x.complete? })
    
    # Add the next link to the chain
    extended_results = []
    chain_results.each do |c|
      extended_results += c.add_link(theory_2)
    end
    chain_results = extended_results

    # Add the next link to the chain
    extended_results = []
    chain_results.each do |c|
      extended_results += c.add_link(theory_3)
    end
    chain_results = extended_results    

    # Add the next link to the chain
    extended_results = []
    chain_results.each do |c|
      extended_results += c.add_link(theory_4)
    end
    chain_results = extended_results        
    
    # Check the results - at least one the chains should be complete now
    assert_equal(true,chain_results.all? {|x| x.kind_of?(Chain)})      
    #assert_equal(true,chain_results.any? {|x| x.complete?})
    #assert_equal(1,chain_results.select {|x| x.complete?}.length)
    
    # Implement the completed chain
    #complete_chain = chain_results.select {|x| x.complete?}.first
    #assert_equal(6,complete_chain.unify_chain.theory_variables.length)
    
  end
  
  def test_variables_creation_with_case_1
    
    # Create demonstration #1
    # (just return the first parameter)
    demo_1_test_case_1 = CTestCase.new 
    demo_1_test_case_1[:params] = ['sparky']
    demo_1_test_case_1[:output] = 'sparky'
    demo_1_test_case_2 = CTestCase.new
    demo_1_test_case_2[:params] = ['kel']
    demo_1_test_case_2[:output] = 'kel'
    demo_1_test_cases = [
      demo_1_test_case_1,demo_1_test_case_2
    ]    
    
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
    runtime_method = RuntimeMethod.new(MethodUsage.new(MethodParameter.new))    
    
    assert_equal(3,chain.variables_creation.length)
    
  end
  
#  # Add the theories needded to create a simple 'if' runtime method
#  #
#  # def method_1(var1)
#  #   if var1 == 'something'
#  #     return 'exist'
#  #   end
#  #   return 'does not exists'
#  # end
#  #
#  # but also include the values of each of the values.
#  #
#  def test_add_link_to_3_with_values
#    
#    theory_1 = Theory.load_theory(20) 
#    theory_2 = Theory.load_theory(14)
#    theory_3 = Theory.load_theory(15)
#    theory_4 = Theory.load_theory(12)
#    
#    # Create te head for the theory
#    head_result_one = TheoryResult.new(StringToTheory.run("if(var2[var3].kind_of?(CTestCase))\nreturn true\nend"))
#    head_result_two = TheoryResult.new(
#      StringToTheory.run("if((var2[var3][:params][var6] == var2[var4][:params][var6])==false)\nreturn true\nend")
#    )
#    head = Theory.new([],nil,[head_result_one,head_result_two])     
#    
#  end
  
#  def test_solvable_passing_no_theories
#    
#    # Create the initial starting chain from pre-existing chain
#    directory_path = $LOC+File.join('test','fixtures','chains','3')
#    raise StandardError.new("chain 3 does not exist") unless(File.exists?(directory_path))
#    dump_file = File.open(File.join(directory_path,'dump'),'r')    
#    initial_chain = Marshal.load(dump_file)       
#    
#    finish = Parser.run("if(runtime_method.all_pass?(test_cases))\nreturn true\nend")
#    
#    assert_equal(false,initial_chain.solvable?(finish,[]))
#    
#  end
  
#  def test_solvable_with_one_theory_that_solves_it
#    
#    # Create the initial starting chain from pre-existing chain
#    directory_path = $LOC+File.join('test','fixtures','chains','1')
#    raise StandardError.new("chain 1 does not exist") unless(File.exists?(directory_path))
#    dump_file = File.open(File.join(directory_path,'dump'),'r')    
#    initial_chain = Marshal.load(dump_file)
#    
#    theory_19 = Theory.load_theory(19)
#    
#    finish = Parser.run("if(runtime_method.all_pass?(test_cases))\nreturn true\nend")
#    assert_equal(true,initial_chain.solvable?(finish,[theory_19]))
#    
#  end
  
#  def test_solvable_with_case_1
#    # TODO  This works but takes longer than I would expect.
#    
#    # Create the initial starting chain from pre-existing chain
#    directory_path = $LOC+File.join('test','fixtures','chains','3')
#    raise StandardError.new("chain 3 does not exist") unless(File.exists?(directory_path))
#    dump_file = File.open(File.join(directory_path,'dump'),'r')    
#    initial_chain = Marshal.load(dump_file)  
#    
#    theory_1 = Theory.load_theory(20) 
#    theory_2 = Theory.load_theory(14)
#    theory_3 = Theory.load_theory(15)
#    theory_4 = Theory.load_theory(12)
#
#    finish = Parser.run("if(runtime_method.all_pass?(test_cases))\nreturn true\nend")
#    assert_equal(true,initial_chain.solvable?(finish,[theory_1,theory_2,theory_3,theory_4]))
#    
#  end
#  
#  def test_solvable_with_case_1_and_missing_theory
#
#    # Create the initial starting chain from pre-existing chain
#    directory_path = $LOC+File.join('test','fixtures','chains','3')
#    raise StandardError.new("chain 3 does not exist") unless(File.exists?(directory_path))
#    dump_file = File.open(File.join(directory_path,'dump'),'r')    
#    initial_chain = Marshal.load(dump_file)  
#    
#    theory_1 = Theory.load_theory(20)  
#    theory_2 = Theory.load_theory(14)
#    theory_3 = Theory.load_theory(15)
#    theory_4 = Theory.load_theory(12)
#    
#    finish = Parser.run("if(runtime_method.all_pass?(test_cases))\nreturn true\nend")
#    assert_equal(false,initial_chain.solvable?(finish,[theory_1,theory_2,theory_3]))
#    assert_equal(false,initial_chain.solvable?(finish,[theory_1,theory_2,theory_4]))
#    assert_equal(false,initial_chain.solvable?(finish,[theory_1,theory_3,theory_4]))
#    assert_equal(false,initial_chain.solvable?(finish,[theory_2,theory_3,theory_4]))
#    
#  end

end