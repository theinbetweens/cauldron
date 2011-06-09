require 'required'
require 'test/unit'

class TestArrayAccess < Test::Unit::TestCase
  
  def setup
    animals = ['spider','bear','rat'].to_var    
    @index_0 = ArrayAccess.new(animals,Literal.new(0))
    @index_1 = ArrayAccess.new(animals,Literal.new(1))
    @index_2 = ArrayAccess.new(animals,Literal.new(2))
    @index_3 = ArrayAccess.new(animals,Literal.new(3))
    
    @spider_index_variable = FixnumVariable.new(0)
    @spider_access = ArrayAccess.new(animals,@spider_index_variable)
    
    @characters = ['Manny','Guybrush','Elaine',9].to_var
    @manny_access = ArrayAccess.new(@characters,Literal.new(0))
    @access_9 = ArrayAccess.new(@characters,Literal.new(3))
    @nil_access = ArrayAccess.new(@characters,Literal.new(4))
    
  end
  
  def teardown
    System.reset
  end  

  def test_write
    assert_equal('var_0[0]',@index_0.write)
    assert_equal('var_0[1]',@index_1.write)
    assert_equal('var_0[2]',@index_2.write)
    assert_equal('var_0[3]',@index_3.write)    
    assert_equal('var_0[3]',@index_3.write)        
    
    # Create methods to access
    assert_equal('var_0[var_'+@spider_index_variable.variable_id.to_s+']',@spider_access.write)
    
  end
  
  def test_response
    assert(@manny_access.response.kind_of?(StringVariable))     
    assert_equal('Manny',@manny_access.response.value)         
    assert_equal(9,@access_9.response.value)             
    assert_equal(nil,@nil_access.response.value)                 
  end
      
  def test_equivalent?
    assert(@manny_access.equivalent?(@manny_access))
    assert_equal(false,@spider_access.equivalent?(@manny_access))    
    
    # Test accessing using the same varaible
    array_access_1 =  ArrayAccess.new(@characters,1.to_literal)
    array_access_2 =  ArrayAccess.new(@characters,2.to_literal)
    assert_equal(false,array_access_1.equivalent?(array_access_2))
    
    # Check a duplicate declaration are equivalent
    assert(array_access_1.equivalent?(ArrayAccess.new(@characters,1.to_literal)))
    
    # Check that duplcate arrays and keys are caught
    assert(ArrayAccess.new(['warren'].to_literal,0.to_literal).equivalent?(ArrayAccess.new(['warren'].to_literal,0.to_literal)))
    
  end
      
end