require 'required'
require 'test/unit'

class TestTheoryAction < Test::Unit::TestCase
  
  def setup
    @theory_action_one = TheoryAction.new(
      TheoryStatement.new(StringToTheory.run('Statement.new(Return.new,var9)')),
      StringToTheory.run('var1.statement_id')
    )
  end
  
  def teardown
    System.reset
    RuntimeMethod.reset_global_id        
  end
  
  # Test the creation of a very simple theory action that just adds a 
  # return statement to the runtime method.
  #
  def test_initialize_1
      assert_nothing_raised(){TheoryAction.new(StringToTheory.run('return var9'),StringToTheory.run('var1.statement_id'))}
      assert_raises(ArgumentError){TheoryAction.new()}
      assert_equal(
        "<runtime_method>.add_statement_at(return #{TheoryVariable.variable_colour(9)}var9#{TheoryVariable::NORMAL},#{TheoryVariable.variable_colour(1)}var1#{TheoryVariable::NORMAL}.statement_id)",
        TheoryAction.new(StringToTheory.run('return var9'),StringToTheory.run('var1.statement_id')).describe
      )
  end
  
  def test_initialize_2
    action_one = TheoryAction.new(
      TheoryStatement.new(
        StringToTheory.run('Statement.new(Parser.run("var4 = var1.params[0]"))')
      ),
      StringToTheory.run('var1.statement_id')
    )
    assert_equal(
      "<runtime_method>.add_statement_at(Statement.new(Parser.run('var4 = var1.params[0]')),#{TheoryVariable.variable_colour(1)}var1#{TheoryVariable::NORMAL}.statement_id)",
      action_one.describe  
    )
  end    
  
  def test_initialize_3
    action = TheoryAction.new(
      TheoryStatement.new(StringToTheory.run('Statement.new(Unknown.new,var1,Addition.new,var2)')),
      StringToTheory.run('var1.statement_id')
    )
    assert_equal(
      "<runtime_method>.add_statement_at(Statement.new(Unknown.new, #{TheoryVariable.variable_colour(1)}var1#{TheoryVariable::NORMAL}, Addition.new, #{TheoryVariable.variable_colour(2)}var2#{TheoryVariable::NORMAL}),#{TheoryVariable.variable_colour(1)}var1#{TheoryVariable::NORMAL}.statement_id)",
      action.describe  
    )
  end
  
  def test_theory_variables
    assert_equal(1,@theory_action_one.theory_variables.length)
  end
  
  def test_map_to_with_simple_action
    assert_equal(
      "<runtime_method>.add_statement_at(Statement.new(Return.new, <test_cases>[0][:output]),#{TheoryVariable.variable_colour(1)}var1#{TheoryVariable::NORMAL}.statement_id)",
      @theory_action_one.map_to({9=>Parser.run('test_cases[0][:output]')}).describe
    )
  end
  
  def test_map_to_case_1_theory_1_action
    action = TheoryAction.new(
      TheoryStatement.new(StringToTheory.run(
          'IfStatement.new(var2[var3][:params][var6],Equivalent.new,var2[var3][:output])'
        )
      ),
      StringToTheory.run('var1.statement_id')
    )
    mapping = {2=>IntrinsicTestCases.new,3=>Literal.new(0),6=>0.to_literal}
    assert_equal(
      "<runtime_method>.add_statement_at(IfStatement.new(<test_cases>[0][:params][0], Equivalent.new, <test_cases>[0][:output]),#{TheoryVariable.variable_colour(1)}var1#{TheoryVariable::NORMAL}.statement_id)",
      action.map_to(mapping).describe
    )
  end    
  
end