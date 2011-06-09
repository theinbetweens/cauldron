require 'required'
require 'test/unit'

class TestClassMethodCallContainer < Test::Unit::TestCase
  
  def setup
    
    # Create a simple method call var_a = MethodUsage.new
    @simple_method_usage = ClassMethodCallContainer.new(MethodUsageClass.new,New.new)          
    
    # Create a simple method usage instance
    @simple_method_usage_var = MethodUsage.new().to_var
    @simple_runtime_method_instance = ClassMethodCallContainer.new(RuntimeMethodClass.new,New.new,@simple_method_usage_var)
          
  end
  
  def teardown
    System.reset
    RuntimeMethod.reset_global_id    
  end
  
  def test_select_all
    
    # Test where method doesn't exist
    assert_equal(0,@simple_method_usage.select_all {|x| x.kind_of?(MethodUsageVariable)}.length)
    
    assert_equal(
      @simple_method_usage_var.variable_id,
      @simple_runtime_method_instance.select_all {|x| x.kind_of?(Variable)}.first.variable_id
    )
   
  end
  
end