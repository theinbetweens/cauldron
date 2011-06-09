# This meant to test that the variables requirements change to reflect
# the context they are accessed.
#

require 'required'
require 'test/unit'

class TestContextualVariable < Test::Unit::TestCase
  
  def setup
    
  end
  
  def teardown
    System.reset
    RuntimeMethod.reset_global_id
  end  
  
  # This test checks that variables taken on the appropriate requirements
  # based on their position within a statement and then method.
  #
  # def method_1(param_1)
  #   var1 = param1.chop
  #   var2 = var1.length
  # end
  # 
  # where param_1 = 'test'
  #
  def test_method_describtion
    
    # Create the var1 - this should haven't any requirements individually
    var1 = Unknown.new()       
    assert_equal(0,var1.length)
    
    # Create the first statement with var1 in it e.g. var2 = var1.chop
    chop_call = InstanceCallContainer.new(Unknown.new,Chop.new)
    first_statement = DeclarationStatement.new(var1,Equal.new,chop_call)
    
    # Check that the variables inside the first statement don't have any requirements
    assert_equal(0,first_statement[0].length)
    assert_equal(0,first_statement[2].subject.length)
    
    # Check that the instance call includes a requirement
    assert_equal(1,chop_call.find_variable(chop_call.variable_id).length)
    
    # Check that they have the correct requirements in the context of the statement
    # TODO  I think the whole Unknown class is redundent
    assert_equal(2,first_statement.find_variable(chop_call.subject.variable_id).length)
    
    # Confirm the length of the variable hasn't changed
    assert_equal(0,var1.length)
    
    # Create the second scope variable
    var2 = Unknown.new()
    assert_equal(0,var2.length)
    assert_not_equal(var1.variable_id,var2.variable_id)
    
  end
  
  # This test checks the the declared variable in the following statement
  #
  # varA = varB-varC
  #
  # has the contextual requirement
  #
  # self = varB-varC
  #
  def test_declared_variables_in_statement_with_multiple_variables
    
    # Create the statement 
    declared_variable = Unknown.new
    varB = Unknown.new
    varC = Unknown.new
    statement = Statement.new(declared_variable,Equal.new,varB,Subtract.new,varC)
    
    # Check the number of elmements in the statement
    assert_equal(5,statement.length)
    
    # Retrieve the contextual declared variable
    contextual_variable = statement.contextual_variable(declared_variable.variable_id)
    
    # Confirm a variable was returned
    assert(contextual_variable.kind_of?(Variable))
    
  end
  
end