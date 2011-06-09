require 'required'
require 'test/unit'

class TestStringVariable < Test::Unit::TestCase
  
  def setup
    
    # Create a simple fixnum for testing
    @var_manny = StringVariable.new('manny')

  end
  
  def teardown
System.reset
    RuntimeMethod.reset_global_id
  end  

  def test_copy
    
    # Test a simple fixnum example cap be copied 
    assert_nothing_raised(){@var_manny.copy}    
    assert_equal(@var_manny.variable_id,@var_manny.copy.variable_id)
    
  end
  
  # 
  def test_instance_calls
    
    # Confirm the datatype of all the returned elements in an array
    assert(@var_manny.instance_calls.kind_of?(Array))
    @var_manny.instance_calls.each do |instance_call|
      assert(instance_call.kind_of?(InstanceCallContainer))
    end
    
  end
  
end