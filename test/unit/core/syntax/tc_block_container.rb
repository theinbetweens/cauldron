require 'required'
require 'test/unit'

class TestBlockContainer < Test::Unit::TestCase
  
  def setup
    
    # Create block containers with different numbers of variables
    @block_container_1 = BlockContainer.new('lotus'.to_var)
    @block_container_2 = BlockContainer.new(9.to_var,'test'.to_var)
    
  end
  
  def teardown
System.reset
    RuntimeMethod.reset_global_id
  end  

  def test_write
    assert_equal('|var_0|',@block_container_1.write)
    assert_equal('|var_1, var_2|',@block_container_2.write)
  end
  
  def test_copy
    assert_equal(@block_container_1.length,@block_container_1.copy.length)
    assert_equal(@block_container_2.length,@block_container_2.copy.length)
    assert_equal(@block_container_1.first.variable_id,@block_container_1.copy.first.variable_id)
    assert_equal(@block_container_2.first.variable_id,@block_container_2.copy.first.variable_id)    
    assert_equal(@block_container_2.last.variable_id,@block_container_2.copy.last.variable_id)        
  end
      
end