require 'required'
require 'test/unit'

class TestFixnumVariable < Test::Unit::TestCase
  
  def setup
    
    # Create a simple fixnum for testing
    @var_8 = FixnumVariable.new(8)
    
  end
  
  def teardown
    System.reset
  end  

  def test_copy
    
    # Test a simple fixnum example cap be copied 
    assert_nothing_raised(){@var_8.copy}    
    assert_equal(@var_8.variable_id,@var_8.copy.variable_id)
    assert_not_nil(@var_8.uniq_id)
    assert_equal(@var_8.uniq_id,@var_8.copy.uniq_id)    
    
  end
  
  def test_variable_id=
    
    # Checks that non fixnum instances can edit the variable id
    assert_nothing_raised(){@var_8.variable_id = 3}
    
  end  
  
  # Checks that the description is written correctly.  It should contain
  # a newline character at the end because the description will probably
  # require an each_line call made to it.
  #
  def test_describe
    assert_equal("[FixnumVariable] 8\n",@var_8.describe)
  end
  
  # Check the instance calls a single fixnum variable can create.  Currently
  # there aren't any but that might change.
  #
  def test_instance_calls
    assert_equal(0,@var_8.instance_calls().length)
  end
  
  def test_to_declaration
    assert_nothing_raised() {@var_8.to_declaration}
    assert_equal('FixnumVariable.new(8)',@var_8.to_declaration.write)
  end
  
end