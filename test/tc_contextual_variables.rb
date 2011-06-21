# This meant to test that the variables requirements change to reflect
# the context they are accessed.
#

# TODO  This can go!

require 'required'
require 'test/unit'

class TestContextualVariable < Test::Unit::TestCase
  
  def setup
    
  end
  
  def teardown
    System.reset
    RuntimeMethod.reset_global_id
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