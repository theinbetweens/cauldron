require 'required'
require 'test/unit'

class TestMethodParameterVariable < Test::Unit::TestCase
  
  def setup
  end
  
  def teardown
    System.reset
    RuntimeMethod.reset_global_id
  end  

  def test_initialize
    assert_nothing_raised(){MethodParameter.new('Grim'.to_requirement)}
  end
  
  def test_initialize_variable_id_is_created
    assert(MethodParameter.new('Grim'.to_requirement).variable_id.kind_of?(Fixnum))
  end
      
end