require 'required'
require 'test/unit'

class TestVariable < Test::Unit::TestCase
  
  def setup    
    
    # Create a number of variables to use when testing
    @string_var = 'test'.to_var 
    @manny_var = 'manny'.to_var        
    
    # Simple chop instance call
    @ruby_string = 'ruby'.to_var
    @ruby_chop = InstanceCallContainer.new(@ruby_string,Chop.new)
        
  end
  
  def teardown
    System.reset
  end
  
  def test_variable_access
    
    # Create a simple string variable
    var1 = 'test'.to_var
    
    # Confirm that the variable isn't literalisable?, since it has no literal value
    assert_equal(true,var1.literalisable?)
    
    # Confirm that the variable is written properly
    assert_equal('var_'+var1.variable_id.to_s,var1.write)
    
  end
  
  def test_variable_copy
    
    # Create a simple string variable
    var1 = 'test'.to_var
    
    # Copy the variable and confirm data type
    copied_var1 = var1.copy
    assert_equal( true,copied_var1.kind_of?(Variable) ) 
    
    # Confirm that both variables have the same data type
    assert_equal(var1.variable_id,copied_var1.variable_id,'Copied variable doesn\'t match original')
    
    # Confirm the length of the variables
    assert_equal(var1.length,copied_var1.length)
    
  end
  
end