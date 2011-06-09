require 'required'
require 'test/unit'

# Simple tests for the requirements class.
#
class TestRequirement < Test::Unit::TestCase
  
  def setup
    
  end
  
  def teardown
System.reset
    RuntimeMethod.reset_global_id    
  end
  
  def test_structure_match_method
    
    # Create a simple requirement to test the structure match with
    must_be_an_eight = Requirement.new(This.new,Equal.new,Literal.new(8))
    
    # Check that the structure matches the requirement
    assert(must_be_an_eight.structure_match?([This,Equal,Literal]))
    
    # Check that a longer structure fails
    assert_equal(false,must_be_an_eight.structure_match?([This,Equal,Literal,Subtract]))
    
  end
  
end