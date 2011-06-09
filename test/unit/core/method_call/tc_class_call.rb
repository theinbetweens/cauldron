require 'required'
require 'test/unit'

class TestClassCall < Test::Unit::TestCase
  
  def setup

  end
  
  def teardown
    CodeHandler.reset_global_id
System.reset
    RuntimeMethod.reset_global_id   
  end  
  
  def test_copy
    assert(true,ClassCall.new.copy.kind_of?(ClassCall))
  end
        
end