require 'required'
require 'test/unit'

class TestDeclareVariableAsVariableStructure < Test::Unit::TestCase
  
  def setup
    
    # Create the structure instance that generates the appropriate statement
    @statement_generator = DeclareVariableAsVariableStructure.new
    
    # Create some simple variable declarations
    @fixnum_variable = FixnumVariable.new(8)
    @manny_variable = StringVariable.new('manny')    
    
  end
  
  def teardown
    System.reset
  end
  
  def test_statements
    
    # Test that "var = var(8)" can be created   
    assert_equal(1,@statement_generator.statements([@fixnum_variable]).length)   
    assert(@statement_generator.statements([@fixnum_variable]).first.kind_of?(Statement))   
    assert_equal(@statement_generator.length,@statement_generator.statements([@fixnum_variable]).first.length)  

    assert_equal(3,@statement_generator.statements([@manny_variable]).length)   
    assert_equal(0,@statement_generator.statements([]).length)    
    
    # Attempt to generate structures that generate string variables
    assert_equal(3,@statement_generator.statements([@manny_variable]).length)  
    
    # Attempt to generate a string+string statement
    le = 'Le'.to_var
    chuck = 'Chuck'.to_var
    assert_equal(6,@statement_generator.statements([le,chuck]).length)
    
    # Test that declared variables can be retrieved from statement variabies
    # e.g. var = statement_var.declared_variable
    statement_var_a_unknown = Unknown.new
    statement_var_a = Statement.new(statement_var_a_unknown,Equal.new,8.to_literal).to_var
    # TODO  I'm not sure I should allow the re-dclaration of variables here
    assert_equal(2,@statement_generator.statements([statement_var_a]).length)
    assert_equal(
      ' = var_'+statement_var_a.variable_id.to_s+'.declared_variable',
      @statement_generator.statements([statement_var_a]).last.write[6..35]
    )    
    
    # Check that the 'push' method isn't used in statement declarations
    # Otherwise we generate allot of redundant variables.
    # e.g. 
    # var_a = ['test','asdf']
    # var_b = var_a.push('test2')
    #
    # var_a and var_b are essentially the same variable.
    options_a = [
      Statement.new(Return.new,6.to_literal).to_var,
      RuntimeMethod.new(MethodUsage.new).to_var
    ]
    assert_equal(3,@statement_generator.statements(options_a).length)
    
  end
  
end

