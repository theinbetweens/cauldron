require 'required'
require 'test/unit'

class TestHash < Test::Unit::TestCase
  
  def setup
    @hash_a = {:mass_effect,'awesome' }
  end
  
  def teardown
System.reset
    RuntimeMethod.reset_global_id
  end  
  
  def test_copy
    assert_nothing_raised(){@hash_a.copy}
    assert(@hash_a.copy.kind_of?(Hash))
    assert_equal(@hash_a.write,@hash_a.copy.write)
    assert_not_equal(@hash_a.copy.shift.object_id,@hash_a.copy.shift.object_id)
  end
  
  def test_copy_with_mapping_hash    
    mapping = {
      5 => Parser.run('test_cases'),
      6 => Parser.run('0'),
      1 => Parser.run('last_runtime_method'),
      2 => Parser.run('runtime_method'),
      3 => Parser.run('1'),
      4 => Parser.run('0')
    }
    assert_equal(
      6,
      mapping.copy.length
    )
    copied = mapping.copy
    copied[6] = 'Warren'
    assert_not_equal(copied[6].object_id,mapping[6].object_id)
    assert_equal(copied.length,mapping.length)
  end
      
end