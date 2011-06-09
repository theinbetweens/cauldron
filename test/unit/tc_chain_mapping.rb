require 'required'
require 'test/unit'

class TestInstanceCallStructure < Test::Unit::TestCase
  
  def setup
    
  end
  
  def teardown
    System.reset
    RuntimeMethod.reset_global_id
  end  

  def test_find_global_with_simple_mapping
    
    starting_mapping = { 
      0 => {:head=>8,0=>0,1=>2}
    }
    chain_mapping = ChainMapping.new(starting_mapping)
    assert_equal(0,chain_mapping.find_global(:head,8))
    assert_equal(0,chain_mapping.find_global(1,2))
    assert_equal(0,chain_mapping.find_global(0,0))
    assert_equal(nil,chain_mapping.find_global(0,3))
              
  end
  
  def test_find_global_with_medium_mapping
    starting_mapping = { 
      0 => {:head=>0,0=>0,1=>4},
      3 => {:head=>3,0=>1,1=>5},
      5 => {:head=>5,0=>2,1=>6,:tail=>7},
      6 => {:head=>6,0=>4,1=>8},
    }
    chain_mapping = ChainMapping.new(starting_mapping)
    assert_equal(0,chain_mapping.find_global(:head,0))
    assert_equal(5,chain_mapping.find_global(:head,5))
    assert_equal(5,chain_mapping.find_global(0,2))
    assert_equal(6,chain_mapping.find_global(1,8))
    assert_equal(nil,chain_mapping.find_global(1,9))
    assert_equal(nil,chain_mapping.find_global(4,9))    
  end
  
  def test_add_mapping
    starting_mapping = { 
      0 => {:head=>0,4=>0,1=>4},
      3 => {:head=>3,4=>1,1=>5},
      5 => {:head=>5,4=>2,1=>6,:tail=>7},
      6 => {:head=>6,4=>4,1=>8},
    }
    chain_mapping = ChainMapping.new(starting_mapping)
    assert_nothing_raised(){chain_mapping.add_mapping(3,5,7)}
    assert_equal(3,chain_mapping.find_global(5,7))
    assert_equal(3,chain_mapping.find_global(4,1))
    assert_equal(nil,chain_mapping.find_global(5,8))
    
    # Test adding a new global id
    chain_mapping.add_mapping(7,5,9)
    assert_equal(7,chain_mapping.find_global(5,9))
  end

end