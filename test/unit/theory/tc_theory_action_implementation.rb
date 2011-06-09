require 'required'
require 'test/unit'

class TestTheoryActionImplementation < Test::Unit::TestCase
  include ContainsTheories  
  
  def setup
  end

  def teardown
    System.reset
    RuntimeMethod.reset_global_id        
  end
  
  def test_copy
    implementation_0 = load_theory_implementation(0)
    assert_equal(
      implementation_0.action.describe,
      implementation_0.action.copy.describe
    )
  end
  
end