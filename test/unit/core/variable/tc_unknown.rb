require 'required'
require 'test/unit'

class TestUnknown < Test::Unit::TestCase
  
  def setup
  
  end
  
  def teardown
    System.reset
  end  
  
  def test_initialize
  end
  
  # 
  def test_to_var
    assert_nothing_raised(){Unknown.new.to_var}
    assert_equal(89,Unknown.new.to_var(89).variable_id)
    assert_equal(99,Unknown.new.to_var(89,99).uniq_id)    
  end
  
end