$LOAD_PATH << File.expand_path('../../../lib',__FILE__)

require 'cauldron'

require 'test/unit'

class TestTheory < Test::Unit::TestCase
  include ContainsTheories
  
  def setup
    super 
  end
  
  def teardown
    System.reset
    RuntimeMethod.reset_global_id
  end  
  
  # Attempt to create a very basic theory that basic says the following.
  #
  # If two variables have the same length then adding a return statement 
  # which returns the first variable will result in the runtime method being
  # valid for all the cases. 
  #
  def test_initialize_1
    
    # Create the single requirement
    dependent_one = TheoryDependent.new(StringToTheory.run("if(var1.length == var2.length)\nend"))
    action_one = TheoryAction.new(StringToTheory.run('return var1'),StringToTheory.run('var1.statement_id'))
    result_one = TheoryResult.new(Parser.run("if(runtime_method.all_pass?(test_cases))\nreturn true\nend"),true)
    assert_nothing_raised(){Theory.new([dependent_one],action_one,[result_one])}
    
  end
  
  # Test the creation of a theory that has a theory variable in the action that isn't
  # in any dependents.
  #
  def test_initialize_2
    dependent_two = TheoryDependent.new(StringToTheory.run("if(var1.length == var2.length)\nend"))
    action_two = TheoryAction.new(StringToTheory.run('return var3'),StringToTheory.run('var1.statement_id'))
    result_two = TheoryResult.new(Parser.run("if(runtime_method.all_pass?(test_cases))\nreturn true\nend"))    
    assert_nothing_raised(){Theory.new([dependent_two],action_two,[result_two])}        
  end
  
  def test_initialize_3
    dependent_one = TheoryDependent.new(StringToTheory.run("if(var1.length == var2.length)\nend"))
    action_two = TheoryAction.new(
      TheoryStatement.new(
        StringToTheory.run('Statement.new(Parser.run("var4 = var3.params[0]"))')
      ),
      StringToTheory.run('var1.statement_id')
    )
    result_two = TheoryResult.new(StringToTheory.run("if(var3.all_pass?(var4))\nreturn true\nend"))
    assert_nothing_raised(){Theory.new([dependent_one],action_two,[result_two])}
  end
  
  def test_initialize_with_more_than_one_dependent   
    dependent_one = TheoryDependent.new(StringToTheory.run("if(var1.kind_of?(RuntimeMethod))\nreturn true\nend"))
    dependent_two = TheoryDependent.new(StringToTheory.run("if(var1.length == var2)\nreturn true\nend"))
    action = TheoryAction.new(
      TheoryStatement.new(
        StringToTheory.run('Statement.new(Return.new,var1.history.length)')
      ),
      StringToTheory.run('var1.statement_id')
    )
    result_one = TheoryResult.new(StringToTheory.run("if(var1.length == var2)\nreturn true\nend"))
    assert_nothing_raised(){
      Theory.new([dependent_one,dependent_two],action,[result_one])
    }
  end
  
  # https://docs.google.com/a/theinbetweens.co.uk/document/d/1i0PvZRHf_rZ-6Yusck7TANCyxgmRjLiLsLwYACKBuWs/edit?hl=en_GB#
  def test_initialize_with_case_1_theory_1
    dependent_one = TheoryDependent.new(StringToTheory.run("if(var2[var3].kind_of?(CTestCase))\nreturn true\nend"))
    dependent_two = TheoryDependent.new(StringToTheory.run("if(var6.kind_of?(Fixnum))\nreturn true\nend"))
    dependent_three = TheoryDependent.new(
      StringToTheory.run("if((var2[var3][:params][var6] == var2[var4][:params][var6])==false)\nreturn true\nend")
    )
    action = TheoryAction.new(
      TheoryStatement.new(StringToTheory.run(
        'IfStatement.new(var2[var3][:params][var6],Equivalent.new,var2[var3][:output])'
      )),
      StringToTheory.run('var1.statement_id')
    )
    result_one = TheoryResult.new(StringToTheory.run(
      "if(var1.history(var2[var3][:params]).any? { |x| x.statement_id == var1.last.statement_id })\nreturn true\nend"
    ))
    result_two = TheoryResult.new(StringToTheory.run(
      "if((var1.history(var2[var4][:params]).any? { |x| x.statement_id == var1.last.statement_id })==false)\nreturn true\nend"
    ))    
    assert_nothing_raised(){
      Theory.new(
        [dependent_one,dependent_two,dependent_three],
        action,
        [result_one,result_two]
      )
    }
  end
  
  # fixture theory 13
  def test_initialize_with_case_1_theory_1_with_last_runtime
    dependent_one = TheoryDependent.new(StringToTheory.run("if(var2[var3].kind_of?(CTestCase))\nreturn true\nend"))
    dependent_two = TheoryDependent.new(StringToTheory.run("if(var6.kind_of?(Fixnum))\nreturn true\nend"))
    dependent_three = TheoryDependent.new(
      StringToTheory.run("if((var2[var3][:params][var6] == var2[var4][:params][var6])==false)\nreturn true\nend")
    )
    action = TheoryAction.new(
      TheoryStatement.new(StringToTheory.run(
        'IfStatement.new(var2[var3][:params][var6],Equivalent.new,var2[var3][:output])'
      )),
      StringToTheory.run('var1.statement_id')
    )
    result_one = TheoryResult.new(StringToTheory.run(
      "if(var5.history(var2[var3][:params]).any? { |x| x.statement_id == var1.last.statement_id })\nreturn true\nend"
    ))
    result_two = TheoryResult.new(StringToTheory.run(
      "if((var5.history(var2[var4][:params]).any? { |x| x.statement_id == var1.last.statement_id })==false)\nreturn true\nend"
    ))    
    assert_nothing_raised(){
      Theory.new(
        [dependent_one,dependent_two,dependent_three],
        action,
        [result_one,result_two]
      )
    }   
    
  end
  
  # fixture theory 14
  def test_initialize_with_case_1_theory_2

    dependent_one = TheoryDependent.new(StringToTheory.run(
      "if(var1.history(var2[var3][:params]).any? { |x| x.statement_id == var1.last.statement_id })\nreturn true\nend"
    ))
    dependent_two = TheoryDependent.new(StringToTheory.run(
      "if((var1.history(var2[var4][:params]).any? { |x| x.statement_id == var1.last.statement_id })==false)\nreturn true\nend"
    ))
    action = TheoryAction.new(
      TheoryStatement.new(StringToTheory.run('Statement.new(Return.new,var2[var3][:output])')),
      StringToTheory.run('var1.last.statement_id')
    )    
    result_one = TheoryResult.new(StringToTheory.run(
      "if(var1.pass?(var2[var3]))\nreturn true\nend"
    ))
    result_two = TheoryResult.new(StringToTheory.run(
      "if(var1.pass?(var2[var4])==false)\nreturn true\nend"
    ))    
    assert_nothing_raised(){
      Theory.new(
        [dependent_one,dependent_two],
        action,
        [result_one,result_two]
      )
    }   
  end    
  
  def test_initialize_with_case_1_theory_2_with_last_runtime_method
    
    dependent_one = TheoryDependent.new(StringToTheory.run(
      "if(var5.history(var2[var3][:params]).any? { |x| x.statement_id == var1.last.statement_id })\nreturn true\nend"
    ))
    dependent_two = TheoryDependent.new(StringToTheory.run(
      "if((var5.history(var2[var4][:params]).any? { |x| x.statement_id == var1.last.statement_id })==false)\nreturn true\nend"
    ))
    action = TheoryAction.new(
      TheoryStatement.new(StringToTheory.run('Statement.new(Return.new,var2[var3][:output])')),
      StringToTheory.run('var1.last.statement_id')
    )    
    result_one = TheoryResult.new(StringToTheory.run(
      "if(var1.pass?(var2[var3]))\nreturn true\nend"
    ))
    result_two = TheoryResult.new(StringToTheory.run(
      "if(var5.pass?(var2[var4])==false)\nreturn true\nend"
    ))  
    result_three = TheoryResult.new(StringToTheory.run(
      "if(var5.pass?(var2[var3]))\nreturn true\nend"
    ))    
    assert_nothing_raised(){
      Theory.new(
        [dependent_one,dependent_two],
        action,
        [result_one,result_two,result_three]
      )
    }   
  end  
  
  def test_initialize_with_case_1_theory_3
    dependent_one = TheoryDependent.new(StringToTheory.run(
      "if(var1.pass?(var2[var3]))\nreturn true\nend"
    ))
    dependent_two = TheoryDependent.new(StringToTheory.run(
      "if(var1.pass?(var2[var4]) == false)\nreturn true\nend"
    ))
    action = TheoryAction.new(
      TheoryStatement.new(StringToTheory.run('Statement.new(Return.new,var2[var4][:output])')),
      StringToTheory.run('var1.statement_id')
    )
    result_one = TheoryResult.new(StringToTheory.run(
      "if(var1.pass?(var2[var4]))\nreturn true\nend"
    ))    
    assert_nothing_raised(){
      Theory.new(
        [dependent_one,dependent_two],
        action,
        [result_one]
      )
    }
  end
  
  def test_initialize_with_case_1_theory_3_with_last_runtime_method

    dependent_one = TheoryDependent.new(StringToTheory.run(
      "if(var5.pass?(var2[var3]))\nreturn true\nend"
    ))
    dependent_two = TheoryDependent.new(StringToTheory.run(
      "if(var5.pass?(var2[var4]) == false)\nreturn true\nend"
    ))
    action = TheoryAction.new(
      TheoryStatement.new(StringToTheory.run('Statement.new(Return.new,var2[var4][:output])')),
      StringToTheory.run('var1.statement_id')
    )
    result_one = TheoryResult.new(StringToTheory.run(
      "if(var1.pass?(var2[var4]))\nreturn true\nend"
    ))    
    assert_nothing_raised(){
      Theory.new(
        [dependent_one,dependent_two],
        action,
        [result_one]
      )
    }
  end  
  
  def test_initialize_with_case_1_theory_4
    dependent_one = TheoryDependent.new(StringToTheory.run(
      "if(var1.pass?(var2[var3]))\nreturn true\nend"
    ))
    dependent_two = TheoryDependent.new(StringToTheory.run(
      "if(var1.pass?(var2[var4]))\nreturn true\nend"
    ))    
    
    result_one = TheoryResult.new(StringToTheory.run(
      "if(var1.all_pass?(var2))\nreturn true\nend"
    ))        
    
    assert_nothing_raised(){
      Theory.new(
        [dependent_one,dependent_two],
        nil,
        [result_one]
      )
    }        
  end
  
  def test_initialize_with_case_2_theory_1
    # - fixture 16

#    a = BlockStatement.new(
#      Statement.new(
#        InstanceCallContainer.new(
#          Container.new(
#            InstanceCallContainer.new(
#              var1.params[0],StringLength.new
#            ),
#            Subtract.new,
#            1
#          ),
#          Times.new
#        )
#      )
#    )

    # TODO Should probably add a few for more dependents
    # var1 = RuntmeMethod
    # var2 = 0 - .params[0]
    # var3 = TestCases
    # var4 = 0 - the first test case
    # var5 = last_runtime_method
    dependent_one = TheoryDependent.new(
      StringToTheory.run(
        "if(var1.kind_of?(RuntimeMethod))\nreturn true\nend"
      )
    )     
    dependent_two = TheoryDependent.new(
      StringToTheory.run(
        "if(var3[var4].kind_of?(CTestCase))\nreturn true\nend"
      )
    )     
    action = TheoryAction.new(
      TheoryStatement.new(
        StringToTheory.run(
          'BlockStatement.new(Statement.new(InstanceCallContainer.new(Container.new(InstanceCallContainer.new(var1.params[var2],StringLength.new),Subtract.new,1),Times.new)))'
        )
      ),
      StringToTheory.run('var1.statement_id')
    )
    result_one = TheoryResult.new(
      StringToTheory.run(
        "if(var1.history2(var3[var4]).select {|x| x['statement_id'] == var3.last.statement_id} == var3[var4][:params][var2].length-1)\nreturn true\nend"
      )
    )
    assert_nothing_raised(){
      Theory.new(
        [dependent_one,dependent_two],
        action,
        [result_one]
      )
    }
  end  
  
  def test_initialize_with_case_2_theory_2
    # - fixture 17    
    # var1 = RuntmeMethod
    # var2 = 0 - .params[0]
    # var3 = TestCases
    # var4 = 0 - the first test case
    # var5 = last_runtime_method    
    dependent_one = TheoryDependent.new(
      StringToTheory.run(
        "if(var1.history2(var3[var4]).select {|x| x['statement_id'] == var3.last.statement_id} == var3[var4][:params][var2].length-1)\nreturn true\nend"
      )
    )    
    action = TheoryAction.new(
      TheoryStatement.new(
        StringToTheory.run(
          "Statement.new(var1.params[var2],Equal.new,InstanceCallContainer.new(var1.params[var2],Chop.new))"
        )
      ),
      StringToTheory.run('var1.last.statement_id')
    )
    result_one = TheoryResult.new(
      StringToTheory.run(
        "if(var5.history2(var3[var4]).last['variables'].last['value'] == var3[var4][:output].length)\nreturn true\nend"
      )
    )
    assert_nothing_raised(){
      Theory.new(
        [dependent_one],
        action,
        [result_one]
      )
    }   
  end
  
  def test_initialize_with_case_2_theory_3
    # - fixture 18    
    # var1 = RuntmeMethod
    # var2 = 0 - .params[0]
    # var3 = TestCases
    # var4 = 0 - the first test case
    # var5 = last_runtime_method    
    dependent_one = TheoryDependent.new(
      StringToTheory.run(
        "if(var5.history2(var3[var4]).last['variables'].last['value'] == var3[var4][:output].length)\nreturn true\nend"
      )
    )    
    action = TheoryAction.new(
      TheoryStatement.new(
        StringToTheory.run(
          "Statement.new(Return.new,var1.params[var2])"
        )
      ),
      StringToTheory.run('var1.statement_id')    
    )
    result_one = TheoryResult.new(StringToTheory.run(
      "if(var1.pass?(var3[var4]))\nreturn true\nend"
    ))
    assert_nothing_raised(){
      Theory.new(
        [dependent_one],
        action,
        [result_one]
      )
    }       
  end
  
  def test_map_to_case1_theory_1
    
    theory =Theory.load_theory(9)
#    runtime_method = RuntimeMethod.new(MethodUsage.new(MethodParameter.new))
#    test_cases = [
#      {:params=>['something'], :output=>'exists'},
#      {:params=>['my willpower'], :output=>'does not exist'}
#    ]
    mapping = Mapping.new({
      1=>IntrinsicRuntimeMethod.new,
      2=>IntrinsicTestCases.new,
      3=>0.to_literal,
      4=>1.to_literal,
      6=>1.to_literal
    })
    puts theory.write
    puts theory.all_theory_variables.length
    puts theory.map_to(mapping).write
    assert_equal(
      0,
      theory.map_to(mapping).all_theory_variables.length
    )
    
  end
  
  def test_map_to_case_1_theory_2
    theory =Theory.load_theory '10'
    mapping = Mapping.new({
      1=>IntrinsicRuntimeMethod.new,
      2=>IntrinsicTestCases.new,
      3=>0.to_literal,
      4=>1.to_literal,
      6=>1.to_literal
    })
    assert_equal(
      0,
      theory.map_to(mapping).all_theory_variables.length
    )    
  end    
  
  def test_map_to_case_1_theory_3
    theory =Theory.load_theory '11'
    mapping = Mapping.new({
      1=>IntrinsicRuntimeMethod.new,
      2=>IntrinsicTestCases.new,
      3=>0.to_literal,
      4=>1.to_literal,
      6=>1.to_literal
    })
    assert_equal(
      0,
      theory.map_to(mapping).all_theory_variables.length
    )    
  end
  
  def test_map_to_case_1_theory_4
    
    theory =Theory.load_theory '12'
    mapping = Mapping.new({
      1=>IntrinsicRuntimeMethod.new,
      2=>IntrinsicTestCases.new,
      3=>0.to_literal,
      4=>1.to_literal,
      6=>1.to_literal
    })
    assert_equal(
      0,
      theory.map_to(mapping).all_theory_variables.length
    )    
  end      
  
  # Check that a clear description of the theory in an abstract state 
  # can be generated.
  #
  def test_describe
    assert(@theory_1.describe.kind_of?(String))    
    assert(@theory_1.describe.include?('if'))
    assert(@theory_1.describe.include?('action'))
    assert(@theory_1.describe.include?('result'))
  end
  
  def test_all_theory_variables
    assert_equal(3,@theory_1.all_theory_variables.length)
    assert_equal(5,@theory_2.all_theory_variables.length)
  end    
  
  def test_rewrite_permutations
    
    # Find potential literal values 
    potential_values = MappingValues.new([
        Parser.run('test_cases[0][:params][0]'),
        Parser.run('test_cases[0][:params]'),
        Parser.run('test_cases[0][:output]'),
        Parser.run('test_cases'),
        Parser.run('runtime_method')       
    ])
    assert(@theory_1.rewrite_permutations(potential_values).kind_of?(Array))
    assert_equal(60,@theory_1.rewrite_permutations(potential_values).length)
    assert(@theory_1.rewrite_permutations(potential_values).all? {|x| x.kind_of?(TheoryImplementation)})
    
    # Check that all the theory variables have been substituted
    @theory_1.rewrite_permutations(potential_values).each do |x|
      x.dependents.each do |y|
        assert_equal(0,y.theory_variables.length)
      end
    end      
  end
  
  def test_rewrite_permutations_with_a_theory_without_an_action
    potential_values = [
        Parser.run('test_cases[0][:params][0]'),
        Parser.run('test_cases[0][:params]'),
        Parser.run('test_cases[0][:output]'),
        Parser.run('test_cases'),
        Parser.run('runtime_method')       
    ]    
    theory_5 =Theory.load_theory(5)
    assert_equal(
      60,
      theory_5.rewrite_permutations(potential_values).length
    )    
  end    
  
  def test_all_theory_variables_with_a_theory_without_an_action
    theory_4 =Theory.load_theory(4)
    theory_5 =Theory.load_theory(5)
    assert_nil(theory_5.action)
    assert_not_nil(theory_4.action)
    assert_equal(
      3,
      theory_5.all_theory_variables.length
    )
  end
  
  # Check that correct number of orphan variables are detected
  def test_orphan_action_variables
    
    # Create the simple that contains a theory_variable 3 that is only used in the action
    link_one_action = TheoryAction.new(
      TheoryStatement.new(StringToTheory.run('Statement.new(Return.new,var2[var3][:output])')),
      StringToTheory.run('var1.statement_id')
    )
    link_one_result = TheoryResult.new(StringToTheory.run("if(var1.all_pass?(var2))\nreturn true\nend"))
    t = Theory.new([],link_one_action,[link_one_result])
    assert_equal(1,t.orphan_action_variables.length)
    assert_equal(3,t.orphan_action_variables.first.theory_variable_id)
    
  end
  
  def test_find_component
    theory_4 = Theory.load_theory(4)
    assert_equal(
      theory_4.dependents[0].theory_component_id,
      theory_4.find_component(theory_4.dependents[0].theory_component_id).theory_component_id
    )
    assert_equal(
      theory_4.results[0].theory_component_id,
      theory_4.find_component(theory_4.results[0].theory_component_id).theory_component_id
    )    
    
  end
   
end