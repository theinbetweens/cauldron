require 'required'
require 'test/unit'

class TestHackStatement < Test::Unit::TestCase
  
  def setup
  
    @example_hack_statement = HackStatement.new("@var.push({'test':'sadasd','somethingelse':8}")
  end
  
  def teardown
System.reset
    RuntimeMethod.reset_global_id
  end  
  
  def test_write
    assert_equal("@var.push({'test':'sadasd','somethingelse':8}",@example_hack_statement.write)
  end
  
  def test_copy
    assert_nothing_raised(){@example_hack_statement.copy}
    assert_not_nil(@example_hack_statement.copy)
    assert_equal(@example_hack_statement.write,@example_hack_statement.copy.write)    
  end
      
end