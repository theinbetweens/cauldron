require 'required'
require 'test/unit'

class TestArrayVariable < Test::Unit::TestCase
  
  def setup
    @animals = ['spider','bear','rat'].to_var    
    @games = ['Grim Fandango','Fallout'].to_var
    @games.instance_variable = true
  end
  
  def teardown
    System.reset
  end  

  def test_to_declaration
    assert(@animals.to_declaration.kind_of?(VariableDeclaration))
    assert_not_nil(@animals.to_declaration.write,'Should write out command to create array variable')
  end
  
  def test_initialize
    assert_equal(3,@animals.length)
  end
  
  def test_literalise
    assert(@animals.literalise.value.instance_of?(Array))
    assert_equal(3,@animals.literalise.value.length)    
    assert_equal('spider',@animals.literalise.value.first)        
  end
  
  def test_copy
    assert_equal(@animals.length,@animals.copy.length) 
    assert_equal(@animals.variable_id,@animals.copy.variable_id)     
    assert_equal(@animals.first,@animals.copy.first)         
    assert_equal('@var_'+@games.variable_id.to_s,@games.copy.write)         
    assert_not_nil(@animals.uniq_id)
    assert_equal(@animals.uniq_id,@animals.copy.uniq_id)
  end
  
  # Find the following access calls for the array .length [0],[1],[2]
  def test_instance_calls
    assert_equal(4,@animals.instance_calls.length) 
    assert_equal(4,@animals.instance_calls.find_all {|x| x.kind_of?(InstanceCallContainer)}.length)     
    assert_equal(3,@animals.instance_calls.find_all {|x| x.kind_of?(ArrayAccess)}.length)         
  end
  
  def test_write
    assert_equal('var_'+@animals.variable_id.to_s,@animals.write)
    assert_equal('@var_'+@games.variable_id.to_s,@games.write)
  end
  
  def test_instance_variable
    tmp = ['bad','science'].to_var
    assert_equal(false,tmp.instance_variable)
    tmp.instance_variable = true
    assert_equal(true,tmp.instance_variable)
    assert_equal(false,@animals.instance_variable)
    assert_equal(true,@games.instance_variable)    
  end
      
end