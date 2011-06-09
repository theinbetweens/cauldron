require 'required'
require 'test/unit'

class TestVariableDeclaration < Test::Unit::TestCase
  
  def setup
    
    # Create a simple string variable declaration
    @string_var = VariableDeclaration.new('StringVariable','test'.to_declaration)
    
    # Test a array variable declaration
    @animals = VariableDeclaration.new('ArrayVariable',['bear','cat','dog'].to_declaration)
    
  end
  
  def teardown
System.reset
    RuntimeMethod.reset_global_id
  end  
  
  def test_copy
    assert(@string_var.copy.kind_of?(VariableDeclaration))
    assert_not_equal(@string_var.copy.object_id,@string_var.object_id)
    assert(@animals.copy.kind_of?(VariableDeclaration))
    assert_equal(@animals.copy.write,@animals.write)
  end
  
  def test_write
    assert_equal("ArrayVariable.new(['bear', 'cat', 'dog'])",@animals.write)
  end
  
end