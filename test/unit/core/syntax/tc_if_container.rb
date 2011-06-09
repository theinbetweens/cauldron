require 'required'
require 'test/unit'

class TestIfContainer < Test::Unit::TestCase
  
  def setup
    
  end
  
  def teardown
System.reset
    RuntimeMethod.reset_global_id
  end  

  def test_write
    
    # 1.  if(true)
    assert_equal('if(true)',IfContainer.new(True.new).write)
    
    # 2.  if(var_x == 'test')
    unknown_variable_2 = Unknown.new
    if_statement_2 = IfContainer.new(unknown_variable_2,Equivalent.new,Literal.new('test'))
    assert_equal('if(var_'+unknown_variable_2.variable_id.to_s+" == 'test')",if_statement_2.write)
    
  end  
  
  def test_copy
    
    # 1.  Check copy works if(true)
    assert_equal(IfContainer.new(True.new).write,IfContainer.new(True.new).copy.write)
    
    # 2.  Check copy works for "if(var_x == 'test')"
    unknown_variable_2 = Unknown.new
    if_statement_2 = IfContainer.new(unknown_variable_2,Equivalent.new,Literal.new('test'))
    assert_equal(if_statement_2.copy.write,if_statement_2.write)    
    
  end
  
end