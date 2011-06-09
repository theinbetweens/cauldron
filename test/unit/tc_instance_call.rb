require 'required'
require 'test/unit'

class TestInstanceCallContainer < Test::Unit::TestCase
  
  def setup
  
    # Create some example instance calls
    @var_a = 'Stan'.to_var
    @chop_instance_call_a = InstanceCallContainer.new(@var_a,Chop.new)
    @length_instance_call_a = InstanceCallContainer.new(@var_a,StringLength.new)

  end
  
  def teardown
    System.reset
    RuntimeMethod.reset_global_id
  end  
  
  def test_literalise
    
#    # Tests ability to literalise simple 'stan'.chop
#    assert('sta',@chop_instance_call_a.literalise)      
#    
#    # Test simple length call on 'stan'
#    assert('stan'.length,@length_instance_call_a.literalise)      
      
  end
  
  def test_to_declaration
    
    # Check that the correct data type is returned
    assert_kind_of(VariableDeclaration,@chop_instance_call_a.to_declaration)  
    assert_equal("InstanceCallContainer.new(StringVariable.new('Stan'), Chop.new())",@chop_instance_call_a.to_declaration.write)

    # TODO  Test a to_declaration call for a InstanceCallContainer with parameters
    
  end
  
end