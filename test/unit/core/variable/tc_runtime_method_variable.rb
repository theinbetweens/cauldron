require 'required'
require 'test/unit'

class TestRuntimeMethodParameter < Test::Unit::TestCase
  
  def setup
    
    # Create a simple runtime method instance for testing
    @empty_runtime_method = RuntimeMethod.new(MethodUsage.new).to_var
    
  end
  
  def teardown
    System.reset
  end  
  
  def test_copy
    assert_equal(@empty_runtime_method.copy.variable_id,@empty_runtime_method.variable_id)
    assert_equal(@empty_runtime_method.copy.uniq_id,@empty_runtime_method.uniq_id)        
  end
  
  def test_instance_calls
    
    # Check that a .push instance call can be created
    statement_var = Statement.new().to_var
    possible_instance_calls = @empty_runtime_method.instance_calls([statement_var])
    assert_equal(1,possible_instance_calls.length)
    assert_equal(@empty_runtime_method.write+'.push('+statement_var.write+')',possible_instance_calls.first.write)

  end
  
end