require 'required'
require 'test/unit'
 
class TestTheoryGenerator < Test::Unit::TestCase
  include ContainsTheories  
  
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
  
  def test_initialize
    assert_nothing_raised(){TheoryGenerator.new}
  end
  
  # This is testing the generator for the problem that can be solved with 
  # the following solution:
  #
  #  def identifyType(word)
  #    if(word == ‘go’)
  #      return ‘verb’
  #    end
  #    return ‘adjective’
  #  end    
  #  
  def test_generate_with_first_case
    test_case_1 = CTestCase.new 
    test_case_1[:params] = ['something']
    test_case_1[:output] = 'exists'
    test_case_2 = CTestCase.new
    test_case_2[:params] = ['my willpower']
    test_case_2[:output] = 'does not exist'
    test_cases = [
      test_case_1,test_case_2
    ]
    runtime_method = RuntimeMethod.new(MethodUsage.new(MethodParameter.new))
    
  end
  
  def test_generate_theories_for_actions
    
    # The folling are the actions that need included in the statement to solve the problem
    # var1 = RuntimeMethod, var2 = test_cases, var3 = 0, var4 = 0
    action_one = TheoryAction.new(
      TheoryStatement.new(StringToTheory.run(
          'IfStatement.new(var2[var3][:params][var4],Equivalent.new,var2[var3][:output])'
        )
      ),
      StringToTheory.run('var1.statement_id')
    )
    action_two = TheoryAction.new(
      TheoryStatement.new(StringToTheory.run('Statement.new(Return.new,var2[var3][:output])')),
      StringToTheory.run('var1.last.statement_id')
    )
    action_three = TheoryAction.new(
      TheoryStatement.new(StringToTheory.run('Statement.new(Return.new,var2[var4][:output])')),
      StringToTheory.run('var1.statement_id')
    )
    actions = [action_one,action_two,action_three]
    
  end
  
  def test_actions_validate_runtime_method
    
    # The folling are the actions that need included in the statement to solve the problem
    # var1 = RuntimeMethod, var2 = test_cases, var3 = 0, var4 = 0
    action_one = TheoryAction.new(
      TheoryStatement.new(StringToTheory.run(
          'IfStatement.new(var2[var3][:params][var4],Equivalent.new,var2[var3][:output])'
        )
      ),
      StringToTheory.run('var1.statement_id')
    )
    action_two = TheoryAction.new(
      TheoryStatement.new(StringToTheory.run('Statement.new(Return.new,var2[var3][:output])')),
      StringToTheory.run('var1.last.statement_id')
    )
    action_three = TheoryAction.new(
      TheoryStatement.new(StringToTheory.run('Statement.new(Return.new,var2[var4][:output])')),
      StringToTheory.run('var1.statement_id')
    )
    actions = [action_one,action_two,action_three]    
    generator = TheoryGenerator.new
    generator.actions_validate_runtime_method?(@runtime_method,@test_cases,actions)
    
  end
  
  def test_generate_theories_with_some_simple_cases
    
    @set_1_test_cases
    @runtime_method
    mapping = Mapping.new({
      1 => @runtime_method.copy,
      2 => @set_1_test_cases.copy
    })    
    accessors = [
      {:value=>@runtime_method.copy,:statement=>TheoryStatement.new(TheoryVariable.new(1)),:step=>0},
      {:value=>@set_1_test_cases.copy,:statement=>TheoryStatement.new(TheoryVariable.new(2)),:step=>0}
    ]    
    # TODO  I can probably use the runtime method and test case in the mapping
    assert_kind_of(
      Array,TheoryGenerator.new.generate_theories(@set_1_test_cases,@runtime_method,accessors,mapping)
    )
    assert_equal(
      true,
      TheoryGenerator.new.generate_theories(@set_1_test_cases,@runtime_method,accessors,mapping).all? {|x| x.kind_of?(Theory)}
    )

  end

  def test_extend_accessors_with_some_simple_cases
    
    @set_1_test_cases
    @runtime_method
    mapping = Mapping.new({
      1 => @runtime_method.copy,
      2 => @set_1_test_cases.copy
    })    
    accessors = [
      {:value=>@runtime_method.copy,:statement=>TheoryStatement.new(TheoryVariable.new(1)),:step=>0},
      {:value=>@set_1_test_cases.copy,:statement=>TheoryStatement.new(TheoryVariable.new(2)),:step=>0}
    ]
    assert_equal(
      2,
      TheoryGenerator.new.extend_accessors(accessors,mapping,[0,1,2],0).length
    )
    assert_equal(
      9,
      TheoryGenerator.new.extend_accessors(accessors,mapping,[0,1,2],1).length
    )
    # Check that the two test case access has been added e.g. test_case[var3], test_case[var4]
    assert_equal(4,mapping.length)
    
    # NOTE: The step is NOT the number of itterations - it determines what accessors are available 
    #       to construct new statements.
    assert_equal(
      2,
      TheoryGenerator.new.extend_accessors(accessors,mapping,[0,1,2],2).length
    )
  end

  def test_statements_with_first_case
    
    potential_values = MappingValues.new([@set_1_test_cases,@runtime_method])    
    generator = TheoryGenerator.new
    
    # Test one itteration mapping has the correct number of accessors
    one_itteration_accessors, one_itteration_mapping = generator.generate_accessors_and_mapping(@set_1_test_cases,@runtime_method,1)
    assert_equal(one_itteration_accessors.length,one_itteration_accessors.uniq.length) 
    assert_equal(9,one_itteration_accessors.length)
    assert_equal(4,one_itteration_mapping.length)
    
    two_itteration_accessors, two_itteration_mapping = generator.generate_accessors_and_mapping(@set_1_test_cases,@runtime_method,2)
    assert_equal(two_itteration_accessors.length,two_itteration_accessors.collect {|x| x[:statement].write}.uniq.length)
    assert_equal(18,two_itteration_accessors.length)
    assert_equal(5,two_itteration_mapping.length)
     
    three_itteration_accessors, three_itteration_mapping = generator.generate_accessors_and_mapping(@set_1_test_cases,@runtime_method,3)
    assert_equal(29,three_itteration_accessors.length)
    assert_equal(7,three_itteration_mapping.length)
    assert_equal(three_itteration_accessors.length,three_itteration_accessors.collect {|x| x[:statement].write}.uniq.length)
    
    # TODO  Need to check why four itteration doesn't have any effect    
  end
  
  # Check that indexes are re-used.  This allows the test case params to referer to the 
  # same param in the runtime method.
  # 
  # var1.params[var5] == var2[var3][:params][var5]
  # NOTE: var5 are the same reference 
  #
  def test_indexes_are_shared
    potential_values = MappingValues.new([@set_1_test_cases,@runtime_method])    
    generator = TheoryGenerator.new
    accessors, mapping = generator.generate_accessors_and_mapping(@set_1_test_cases,@runtime_method,3)
    assert_equal(true,accessors.any? {|x| x[:statement].write == 'var1.params[var5]'})    
    assert_equal(true,accessors.any? {|x| x[:statement].write == 'var2[var3][:params][var5]'})
  end
  
  # Checks that the theory to add the 'return 'does not exist' statement is generated
  # return var2[var4][:params][var5]
  #
  def test_generate_theories_with_case_1_statement_2
   
    # Create the runtime method with and add the initial "ifstatement" to it
    @runtime_method << Parser.run("if(var0 == 'my willpower')\nend\n")
    
    # Create the mapping for the generator
    mapping = Mapping.new({1 => @runtime_method.copy,2 => @set_1_test_cases.copy})
    mapping[3] = 0
    mapping[4] = 0
    mapping[5] = 1
    # TODO  Should it generate 7 variables surely 6,7 refer to [var2][var3][:params][var6] and [var2][var4][:params][var7]
    #       - I might only want var6 since you can't right code to account for the difference. - Warren this is a proper
    #         don't ignore it.
    mapping[6] = 0
    mapping[7] = 0
    
    # Create the accessors used to generate the action
    accessors = [
      {:value=>'does not exist',:statement=>StringToTheory.run('var2[var4][:params][var5]')},
      {:value=>1,:statement=>StringToTheory.run('var1.last.statement_id')}
    ]
    assert_equal('var2[var4][:params][var5]',accessors[0][:statement].write)
     
    # Check that all the accessors could be generated
    generated_accessors, mapping = TheoryGenerator.new.generate_accessors_and_mapping(@set_1_test_cases,@runtime_method,3)
    accessors.each do |accessor|
      assert(generated_accessors.any? {|x| x[:statement].write == accessor[:statement].write })
    end
    
    # Generate possible theories given the limited number of accessors
    theories = TheoryGenerator.new.generate_theories(@set_1_test_cases,@runtime_method,accessors,mapping)
    assert_equal(
      true,
      theories.any? do |theory| 
        theory.action.write == '<runtime_method>.add_statement_at(Statement.new(Return.new, var2[var4][:params][var5]),var1.last.statement_id)'
      end
    )
    
  end
 
  def test_generate_theories_with_case_1_statement_3
    
    # Create the runtime method with and add the initial "ifstatement" to it
    @runtime_method << Parser.run("if(var0 == 'my willpower')\nend\n")
    @runtime_method.add_statement_at(Parser.run("return 'does not exist'"),@runtime_method.last.statement_id)
    
    # Create the mapping for the generator
    mapping = Mapping.new({1 => @runtime_method.copy,2 => @set_1_test_cases.copy})
    mapping[3] = 0
    mapping[4] = 0
    mapping[5] = 1
    # TODO  Should it generate 7 variables surely 6,7 refer to [var2][var3][:params][var6] and [var2][var4][:params][var7]
    #       - I might only want var6 since you can't right code to account for the difference.
    mapping[6] = 0
    mapping[7] = 0
    
    # Create the accessors used to generate the action
    accessors = [
      {:value=>'exists',:statement=>StringToTheory.run('var2[var4][:output]')},
      {:value=>0,:statement=>StringToTheory.run('var1.statement_id')}
    ]
    assert_equal('var2[var4][:output]',accessors[0][:statement].write)
    
    # Check that all the accessors could be generated
    generated_accessors, mapping = TheoryGenerator.new.generate_accessors_and_mapping(@set_1_test_cases,@runtime_method,3)
    accessors.each do |accessor|
      assert(generated_accessors.any? {|x| x[:statement].write == accessor[:statement].write })
    end    
    
  end
  
  def test_simple_chain_head_creation
    
    # Create the simple runtime method and test cases used to create the head
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
    
    # Generate the head theory - this is the starting point and doesn't have any dependents
    accessors, mapping = TheoryGenerator.new.generate_accessors_and_mapping(test_cases,runtime_method,4,0)
    
    # * Generate all the possible results of this runtime method
    theory_results = TheoryGenerator.new.get_theory_results(accessors)
    
    # * Create the actual head theory
    head_theory = Theory.new([],nil,theory_results,runtime_method.copy)
    
    # Check that the generated theory can be implemented - and all the variables have been replaced
    intrinsic_mapping = TheoryGenerator.new.covert_to_intrinsic_mapping(mapping)
    
    # Go through each result and check that the variables can be mapped to intrinsic values
    head_theory.results.each do |res|
      mapped_res = res.map_to(intrinsic_mapping)
      assert_equal(false,mapped_res.write.include?('var'))
    end
    
    implemented_thoery = head_theory.map_to(intrinsic_mapping)
    assert_not_equal(
      true,
      implemented_thoery.write.include?('var')
    )
    
  end
  
  def test_generate_accessors_and_mapping_with_theory_6
    
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
    
    # Generate the head theory - this is the starting point and doesn't have any dependents
    accessors, mapping = TheoryGenerator.new.generate_accessors_and_mapping(test_cases,runtime_method,7,0)    
    
    # * Generate all the possible results of this runtime method
    theory_results = TheoryGenerator.new.get_theory_results(accessors)
    
    # Check that the results (that would be used in the head) include each do theory_6's dependents
    theory_6 = Theory.load_theory(6)
    theory_6.dependents.each do |theory_dependent|
      assert_equal(true,theory_results.any? {|x| x.write == theory_dependent.write})
    end
    
  end
      
end