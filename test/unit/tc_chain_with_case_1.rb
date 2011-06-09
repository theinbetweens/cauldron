require 'required'
require 'test/unit'

# These are the simple tests for chin that generates the following runtime 
# method.
#
# def method_1(var1)
#   if var1 == 'something'
#     return 'exist'
#   end
#   return 'does not exists'
# end
#
class TestChainWithCase1 < Test::Unit::TestCase
  
  # NOTE: This is the chain without the last runtime included - this will be in a different test case
  def setup
    
    # Create te head for the theory
    head_result_one = TheoryResult.new(StringToTheory.run("if(var2[var3].kind_of?(CTestCase))\nreturn true\nend"))
    head_result_two = TheoryResult.new(
      StringToTheory.run("if((var2[var3][:params][var6] == var2[var4][:params][var6])==false)\nreturn true\nend")
    )
    @head = Theory.new([],nil,[head_result_one,head_result_two])
    @head_values =  { 2=>IntrinsicTestCases.new,
                      3=>IntrinsicLiteral.new(0),
                      4=>IntrinsicLiteral.new(1),
                      6=>IntrinsicLiteral.new(0)
                    }
    
    # Create the four links that needed added to complete the solution
    # ========================== theory 1 ===========================
    t1_dependent_one = TheoryDependent.new(StringToTheory.run("if(var2[var3].kind_of?(CTestCase))\nreturn true\nend"))
    t1_dependent_two = TheoryDependent.new(
      StringToTheory.run("if((var2[var3][:params][var6] == var2[var4][:params][var6])==false)\nreturn true\nend")
    )
    t1_action = TheoryAction.new(
      TheoryStatement.new(StringToTheory.run(
        'OpenStatement.new(IfContainer.new(var1.params[var6],Equivalent.new,var2[var3][:params][var6]))'
      )),
      StringToTheory.run('var1.statement_id')
    )
    t1_result_one = TheoryResult.new(StringToTheory.run(
      "if(var1.history2(var2[var3][:params]).any? { |x| x['statement_id'] == var1.last.statement_id })\nreturn true\nend"
    ))
    t1_result_two = TheoryResult.new(StringToTheory.run(
      "if((var1.history2(var2[var4][:params]).any? { |x| x['statement_id'] == var1.last.statement_id })==false)\nreturn true\nend"
    ))    
    @theory_one = Theory.new(
      [t1_dependent_one,t1_dependent_two],
      t1_action,
      [t1_result_one,t1_result_two]
    )
    @theory_one_values =  { 1=>IntrinsicRuntimeMethod.new,
                            2=>IntrinsicTestCases.new,
                            3=>IntrinsicLiteral.new(0),
                            4=>IntrinsicLiteral.new(1),
                            6=>IntrinsicLiteral.new(0)
                          }    
    
    # =================== Theory 2 ======================
    t2_dependent_one = TheoryDependent.new(StringToTheory.run(
      "if(var1.history2(var2[var3][:params]).any? { |x| x['statement_id'] == var1.last.statement_id })\nreturn true\nend"
    ))
    t2_dependent_two = TheoryDependent.new(StringToTheory.run(
      "if((var1.history2(var2[var4][:params]).any? { |x| x['statement_id'] == var1.last.statement_id })==false)\nreturn true\nend"
    ))
    t2_action = TheoryAction.new(
      TheoryStatement.new(StringToTheory.run('Statement.new(Return.new,var2[var3][:output])')),
      StringToTheory.run('var1.last.statement_id')
    )    
    t2_result_one = TheoryResult.new(StringToTheory.run(
      "if(var1.pass?(var2[var3]))\nreturn true\nend"
    ))
    t2_result_two = TheoryResult.new(StringToTheory.run(
      "if(var1.pass?(var2[var4])==false)\nreturn true\nend"
    ))    
    @theory_two = Theory.new(
      [t2_dependent_one,t2_dependent_two],
      t2_action,
      [t2_result_one,t2_result_two]
    )    
    @theory_two_values =  { 1=>IntrinsicRuntimeMethod.new,
                            2=>IntrinsicTestCases.new,
                            3=>IntrinsicLiteral.new(0),
                            4=>IntrinsicLiteral.new(1),
                            6=>IntrinsicLiteral.new(0)
                          }        
    
    # =================== Theory 3 ======================
    t3_dependent_one = TheoryDependent.new(StringToTheory.run(
      "if(var1.pass?(var2[var3]))\nreturn true\nend"
    ))
    t3_dependent_two = TheoryDependent.new(StringToTheory.run(
      "if(var1.pass?(var2[var4]) == false)\nreturn true\nend"
    ))
    t3_action = TheoryAction.new(
      TheoryStatement.new(StringToTheory.run('Statement.new(Return.new,var2[var4][:output])')),
      StringToTheory.run('var1.statement_id')
    )
    t3_result_one = TheoryResult.new(StringToTheory.run(
      "if(var1.pass?(var2[var4]))\nreturn true\nend"
    ))    
    @theory_three = Theory.new(
      [t3_dependent_one,t3_dependent_two],
      t3_action,
      [t3_result_one]
    )    
    @theory_three_values =  { 1=>IntrinsicRuntimeMethod.new,
                            2=>IntrinsicTestCases.new,
                            3=>IntrinsicLiteral.new(0),
                            4=>IntrinsicLiteral.new(1)
                          }      
    
    # ================== Theory 4 =======================
    # NOTE: This one needs to get it's dependents from theory 3 and 2
    t4_dependent_one = TheoryDependent.new(StringToTheory.run(
      "if(var1.pass?(var2[var3]))\nreturn true\nend"
    ))
    t4_dependent_two = TheoryDependent.new(StringToTheory.run(
      "if(var1.pass?(var2[var4]))\nreturn true\nend"
    ))    
    
    t4_result_one = TheoryResult.new(StringToTheory.run(
      "if(var1.all_pass?(var2))\nreturn true\nend"
    ))        
    @theory_four = Theory.new(
      [t4_dependent_one,t4_dependent_two],
      nil,
      [t4_result_one]
    )    
    
  end

  def teardown
    System.reset
    RuntimeMethod.reset_global_id        
  end  
  
  def test_implement
    
    # Start by creating a complete chain with the values
    chain = Chain.new
    
    # Add the head link to the chain
    chain_results = chain.add_link(@head,@head_values)
    assert_equal(1,chain_results.length)
    
    # Add the next link to the chain
    chain_results = chain_results[0].add_link(@theory_one,@theory_one_values)
    assert_equal(1,chain_results.length)
    
    # Add the second link to the chain
    chain_results = chain_results[0].add_link(@theory_two,@theory_two_values)
    assert_equal(1,chain_results.length)
    
    # Add the third link to the chain
    chain_results = chain_results[0].add_link(@theory_three,@theory_three_values)
    assert_equal(1,chain_results.length)   
    
    # Add the fourth link to the chain
    chain_results = chain_results[0].add_link(@theory_four,@theory_four_values)
    assert_equal(true,chain_results.any? {|x| x.complete?})
    
  end


end
  