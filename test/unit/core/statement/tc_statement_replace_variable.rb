# This test case tests the direct replacement of a variable within a statement.

require 'required'
require 'test/unit'

class TestStatementReplaceVariable < Test::Unit::TestCase
  
  def setup
    
  end
  
  def teardown
System.reset
    RuntimeMethod.reset_global_id    
  end
  
  def test_variable_replacement_with_statement_with_three_variables

    # Create the statement to be tested
    var_A = Unknown.new
    var_B = Unknown.new
    var_C = Unknown.new
    statement = Statement.new(var_C,Equal.new,var_A,Addition.new,var_B)
    assert_nothing_raised(){statement.write}
    
    # Check that the variable id in the statement matches
    assert_equal(var_A.variable_id,statement[2].variable_id)
    
    # Replace the variable in the statement
    var_D = Unknown.new
    assert_nothing_raised(){statement.replace_variable!(var_A.variable_id,var_D)}
    
    # Check that the statement has been updated
    assert_not_equal(var_A.variable_id,statement[2].variable_id)
    assert_equal(var_D.variable_id,statement[2].variable_id)
    
  end
  
  def test_instance_call_replacement
    
    # Create the statement with the instance call
    var_A = Unknown.new
    var_B = 'test'.to_var
    statement = Statement.new(var_A,Equal.new,InstanceCallContainer.new(var_B,Chop.new))
    assert_nothing_raised(){statement.write}    

    # Check that the variable id in the statement matches
    assert_equal(var_B.variable_id,statement[2].variable_id)
    
    # Replace var_B with variable C
    var_C = 'scentilla'.to_var
    assert_nothing_raised(){statement.replace_variable!(var_B.variable_id,var_C)}
    
    # Check that the statement is still valid
    assert(statement[2].kind_of?(InstanceCallContainer))
    assert_equal(var_C.variable_id,statement[2].variable_id)    
    assert(statement[2].subject.kind_of?(Variable))  
      
  end
  
end