require 'required'
require 'test/unit'

class TestLiteralDeclaration < Test::Unit::TestCase
  
  def setup
   
    @marly = 'Marly'
    @string_declaration_a = LiteralDeclaration.new(@marly)
    
    @lions, @tigers, @and, @bears, @oh, @my = 'lions', 'tigers', 'and', 'bears', 'oh', 'my'
    @woods = LiteralDeclaration.new([@lions,@tigers,@and,@bears,@oh,@my])
          
  end
  
  def teardown
System.reset
    RuntimeMethod.reset_global_id    
  end
  
  def test_copy
    assert_equal(@string_declaration_a.copy.write,@string_declaration_a.write)
    assert_not_equal(@string_declaration_a.copy.value.object_id,@string_declaration_a.value.object_id)
    
    # Check Nil can be declared
    assert_nothing_raised(){LiteralDeclaration.new(nil).copy}
    
    # Check that no relationships are maintained in arrays.
    assert_equal(@woods.write,@woods.copy.write)        
    assert_not_equal(@woods.value.first.object_id,@woods.copy.value.first.object_id)

  end
  
end