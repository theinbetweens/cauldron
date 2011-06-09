require 'required'
require 'test/unit'

class TestDeclareNewInstanceStructure < Test::Unit::TestCase
  
  def setup
    
    # Create the structure instance that generates the appropriate statement
    @statement_generator = DeclareNewInstanceStructure.new(MethodUsageClass.new,RuntimeMethodClass.new)
    
  end
  
  def teardown
    System.reset
  end
  
  def test_statements
    
    # Test that "var = MethodUsage.new" can be created
    assert_equal(true,@statement_generator.statements().all? {|x| x.kind_of?(Statement)})
    assert_equal(true,(@statement_generator.statements().select_all {|x| x.kind_of?(MethodUsageClass) }.length > 0))
    
    # Test that "var = RuntimeMethod.new(<#method_usage>")
    method_usage = MethodUsageVariable.new()
    assert_equal(1,@statement_generator.statements([method_usage]).select_all {|x| x.kind_of?(RuntimeMethodClass)}.length)
    
    # Test that a statement that declares a new fixnum as variable can be created
    new_statement_statement_generator = DeclareNewInstanceStructure.new(StatementClass.new)
    assert_equal(
      1,
      new_statement_statement_generator.statements([5.to_literal]).select_all {|x| x.kind_of?(StatementClass)}.length
    )
    assert_equal(
      'var_6 = Statement.new(Unknown.new, Equal.new, 5.to_declaration)',
      new_statement_statement_generator.statements([5.to_literal]).first.write
    )
    
    
  end
  
end
