require 'required'
require 'test/unit'

class TestRuntimeTrackingMethod < Test::Unit::TestCase
  
  def setup
    
    @tracking_variable = ArrayVariable.new([])
    @tracking_variable.instance_variable = true    
    @runtime_tracking_method = RuntimeTrackingMethod.new(@tracking_variable)
    
  end
  
  def teardown
    System.reset 
    RuntimeMethod.reset_global_id
  end  

  def test_write
    
    # Check that evaluated method doesn't generate an error
    #MethodUsage.new(@line,@action,@variables,@local_variables,@statement_id)
    assert_nothing_raised(){
      MethodEvaluation.new.evaluate_method(
        @runtime_tracking_method,ParametersContainer.new(
          0.to_literal,
          12.to_literal,
          [].to_literal,
          'var=test'.to_literal
       ))
     }    

  end

  def test_copy
    assert_nothing_raised(){@runtime_tracking_method.copy}
    assert_equal(@runtime_tracking_method.write,@runtime_tracking_method.copy.write)
  end
  
end