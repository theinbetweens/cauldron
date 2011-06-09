require 'required'
require 'test/unit'

class TestDeclareVariableAsLiteralStructure < Test::Unit::TestCase
  
  def setup
    
    # Create the structure instance that generates the appropriate statement
    @statement_generator = DeclareVariableAsLiteralStructure.new
    
    
  end
  
  def teardown
    CodeHandler.reset_global_id
    System.reset
    RuntimeMethod.reset_global_id    
  end
  
  def test_statements
    
    # Test that "var = 7" can be created
    assert_equal(true,@statement_generator.statements([7.to_literal]).all? {|x| x.kind_of?(Statement)})
    assert_equal(1,@statement_generator.statements([7.to_literal]).length)
    assert_equal('var_2 = 7',@statement_generator.statements([7.to_literal]).first.write())
    
    # Test that "var = 8", "var = 'Grogg'" and 'var = []'
    assert_equal(true,
      @statement_generator.statements([
        8.to_literal,'Grogg'.to_literal,[].to_literal
        ]).all? {|x| x.kind_of?(Statement)}
    )
    assert_equal(true,
      @statement_generator.statements([
        8.to_literal,'Grogg'.to_literal,[].to_literal
      ]).contains? {|x| x.kind_of?(Literal)}
    )    
    
  end
  
end
