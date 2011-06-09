require 'required'
require 'test/unit'

class TestTheoryVariable < Test::Unit::TestCase
  
  def setup
    
  end
  
  def teardown
    System.reset
    RuntimeMethod.reset_global_id        
  end
  
  def test_initialize
    assert_nothing_raised(){TheoryVariable.new(8)}
    assert_raise(ArgumentError) {TheoryVariable.new}
  end
  
  def test_write
    assert_equal(
      TheoryVariable.new(7).describe,
      "#{TheoryVariable.variable_colour(7)}var7#{TheoryVariable::NORMAL}"
    )
    assert_not_equal(
      TheoryVariable.new(14).write,
      "#{TheoryVariable.variable_colour(7)}var7#{TheoryVariable::NORMAL}"
    )
  end  
  
  def test_to_declaration
    assert_equal(TheoryVariable.new(9).to_declaration.write,'TheoryVariable.new(9)')
    assert_not_equal(TheoryVariable.new(10).to_declaration.write,'TheoryVariable.new(9)')
  end
  
  def test_subtacting_arrays
    var8 = TheoryVariable.new(8)
    var7 = TheoryVariable.new(7)
    varX = TheoryVariable.new(8)
    assert_equal(varX.theory_variable_id,var8.theory_variable_id)
    assert_equal(var7.theory_variable_id,7)
    assert_equal(1, ([var8,var7]-[varX]).length)
  end
  
end