require 'required'
require 'test/unit'

class TestStatementStructure2 < Test::Unit::TestCase
  
  def setup
    
    # Create a simple statement structure var = 8
    @fixnum_variable = FixnumVariable.new(8)
    #@fixnum_structure = StatementStructure2.new(StatementStructure2.declared_fixnum)
    
    # Simple string example
    @manny_variable = StringVariable.new('manny')
    
    # Create an a simple chop method
    @chop_le_chuck = InstanceCallStructure.new(StringVariable,Chop.new) 
    
    # Simple statement structure that declares a new string variable
    #@string_structure = StatementStructure2.new(StatementStructure2.declared_string)
    
    # Adding strings structure
    @adding_string = StatementStructure2.new(StatementStructure2.declared_string_addition)        
        
    # Adding fixnum.times structure
    
    67.to_literal        
        
    # CONTINUE I would like to just use StatementStructure with String Variable ?
        
    
    
  end
  
  def teardown
System.reset
    RuntimeMethod.reset_global_id
  end  

  def test_statements

  end

end