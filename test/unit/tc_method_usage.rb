require 'required'
require 'test/unit'

class TestMethodUsage < Test::Unit::TestCase
  
  def setup
  
    # Create a basic method usage example
    @empty_method_usage = MethodUsage.new
    
    # Requires a string variable
    @method_var_a = MethodParameter.new('flipping'.to_requirement)
    @string_paramater_case = MethodUsage.new(@method_var_a)

  end
  
  def teardown
    System.reset
  end  
  
  def test_initialize
    assert_raises(StandardError){MethodUsage.new('bad_boy')}
  end
  
  # 
  def test_to_var
    assert(@empty_method_usage.to_var.kind_of?(MethodUsageVariable))
    assert(@string_paramater_case.to_var.kind_of?(MethodUsageVariable))
    assert_equal(1,@string_paramater_case.to_var.length)
    assert_nothing_raised(){@string_paramater_case.to_var}
    assert_equal(89,@empty_method_usage.to_var(89).variable_id)
    assert_equal(99,@empty_method_usage.to_var(89,99).uniq_id)    
  end
  
end