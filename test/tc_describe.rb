require 'required'
require 'test/unit'

class TestDescribe < Test::Unit::TestCase
  
  def setup
    
  end
  
  def teardown
System.reset
    RuntimeMethod.reset_global_id
  end  

  # There was a bug occuring requirements were added to a variable via
  # the describe call.  This shouldn't be the case.
  #
  def test_nothing_is_added
    
    # Create the method variable for the method (self = 'test')
    requirement = Requirement.new(This.new,Equal.new,Literal.new('test'))
    method_variable = MethodParameter.new(requirement)
    
#    # Create runtime method with one parameter ('test')
#    runtime_method = RuntimeMethod.new(MethodUsage.new(MethodParameter.new))
#    #runtime_method.parameters = [method_variable]
#    
#    # Start by considering the statement varA = varB.chop
#    varB = Unknown.new
#    varC = Unknown.new    
#    consider_statement = DeclarationStatement.new(varC,Equal.new,InstanceCallContainer.new(varB,Chop.new))
#    #populated_method = runtime_method.consider(consider_statement).shift
#    
#    # There should be two variables, one the method variable - what was varB, and the newly declared variable
#    assert(populated_method.available_variables[0].kind_of?(MethodParameter))    
#    assert(populated_method.available_variables[1].kind_of?(Variable))
#    
#    # The declared variable shouldn't have any actual requirements - I think
#    assert(populated_method.available_variables[1].empty?)
#    
#    # Describe the variable and confirm that the variable still doesn't have any requirements
#    populated_method.available_variables[1].describe(populated_method)   
#    assert(populated_method.available_variables[1].empty?)
    
  end
  
end