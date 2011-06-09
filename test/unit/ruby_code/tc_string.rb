require 'required'
require 'test/unit'

class TestString < Test::Unit::TestCase
  
  def setup
    
  end
  
  def teardown
    System.reset
  end  
  
  def test_write
    assert_equal('\'three headed monkey\'','three headed monkey'.write)
    assert_equal("'three headed monkey'",'three headed monkey'.write)    
    assert_equal("'\\'vodoo\\' lady'","'vodoo' lady".write)    
  end

  def test_to_literal
    x = 'test'
    assert(x.to_literal.kind_of?(Literal))
    assert_equal(x,x.to_literal.value)
  end

  def test_to_declared_variable_statement
    x = 'test'
    declared_variable_statement = x.to_declared_variable_statement
    assert_equal("var_0 = 'test'",declared_variable_statement.write)
    assert_equal(0,declared_variable_statement.declared_variable_id)
  end
  
  def test_to_var
    assert_equal(4,'test'.to_var(4,7).variable_id)
    assert_equal(7,'test'.to_var(4,7).uniq_id)
  end  
      
end