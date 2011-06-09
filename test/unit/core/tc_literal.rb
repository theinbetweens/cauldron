require 'required'
require 'test/unit'

class TestLiteral < Test::Unit::TestCase
  
  def setup
    
    @spectre = Literal.new('spectre')  
    @num_2009 = Literal.new(2009)
    
  end
  
  def teardown
    System.reset
    RuntimeMethod.reset_global_id
  end  
  
  def test_initialize
    
    # Attempt to create an unknown literal
    assert_raises(UnliteralisableError){Literal.new(MethodUsage.new)}
    
  end
  
  def test_to_literal_string      
    assert_equal("'spectre'",@spectre.to_literal_string)
    assert_equal("2009",@num_2009.to_literal_string)    
  end
      
end