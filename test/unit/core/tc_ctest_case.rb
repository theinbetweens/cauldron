require 'required'
require 'test/unit'

class TestCTestCase < Test::Unit::TestCase
  
  def setup
    @cauldron_test_case_1 = CTestCase.new() 
    @cauldron_test_case_1[:params] = ['something']
    @cauldron_test_case_1[:output] = 'exists'      
  end
  
  def teardown
    System.reset
    RuntimeMethod.reset_global_id    
  end
  
  def test_cauldron_method_calls
    assert_equal(2,@cauldron_test_case_1.cauldron_method_calls.length)
    assert_equal(
      "[:output]",
      @cauldron_test_case_1.cauldron_method_calls.first
    )
  end
  
end