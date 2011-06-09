require 'required'
require 'test/unit'

class TestMethodUsageVariable < Test::Unit::TestCase
  
  def setup
    @empty_method_usage = MethodUsage.new.to_var
  end
  
  def teardown
System.reset
    RuntimeMethod.reset_global_id
  end  

  def test_to_declaration
    assert(@empty_method_usage.to_declaration.kind_of?(VariableDeclaration))
    assert_not_nil(@empty_method_usage.to_declaration.write,'Should write out command to create array variable')
    assert_equal('MethodUsageVariable.new()',@empty_method_usage.to_declaration.write)
  end
  
  def test_copy
    assert_equal(@empty_method_usage.variable_id,@empty_method_usage.copy.variable_id)
  end
      
end