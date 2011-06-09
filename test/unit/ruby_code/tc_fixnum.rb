require 'required'
require 'test/unit'

class TestFixnum < Test::Unit::TestCase
  
  def setup
  end
  
  def teardown
    System.reset
  end  
  
  def test_to_var
    assert_equal(8,6.to_var(8,9).variable_id)
    assert_equal(9,6.to_var(8,9).uniq_id)    
  end
      
end