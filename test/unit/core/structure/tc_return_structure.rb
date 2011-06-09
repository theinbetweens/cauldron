require 'required'
require 'test/unit'

class TestReturnStructure < Test::Unit::TestCase
  
  def setup
    
    # Create the structure instance that generates the appropriate statement
    @statement_generator = ReturnStructure.new()
    @scabb = 'Scabb'.to_var
    
    
  end
  
  def teardown
    CodeHandler.reset_global_id
System.reset
    RuntimeMethod.reset_global_id    
  end
  
  def test_statements
    
    # Check that 'scabb' was returned
    assert_equal(1,@statement_generator.statements([@scabb]).length)
    assert_equal(
      'return var_'+@scabb.variable_id.to_s,
      @statement_generator.statements([@scabb]).first.write
    )    
    
  end
  
end
