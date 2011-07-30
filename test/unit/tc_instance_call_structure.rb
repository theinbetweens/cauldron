require 'required'
require 'test/unit'

class TestInstanceCallStructure < Test::Unit::TestCase
  
  def setup
    
    # Simple string example
    @lechuck_variable = StringVariable.new('LeChuck')
    
    # Create an a simple chop method
    @chop_le_chuck = InstanceCallStructure.new(StringVariable,Chop.new)
    
  end
  
  def teardown
    System.reset
    RuntimeMethod.reset_global_id
  end  

  def test_instance_calls
    
    # Assert that one instance call is created correctly
    assert_equal(1,@chop_le_chuck.instance_calls([@lechuck_variable]).length)
    assert(@chop_le_chuck.instance_calls([@lechuck_variable]).first.kind_of?(InstanceCallContainer))
    
    # Confirm instance call hasn't any parameters
    assert_equal(0,@chop_le_chuck.instance_calls([@lechuck_variable]).first.length)    
    
    # Assert the no results can be retrieved
    assert_equal(0,@chop_le_chuck.instance_calls([]).length)        
            
  end

end