require 'required'
require 'test/unit'

class TestArray < Test::Unit::TestCase
  
  def setup
    @teams = ['Manchester United','Arsenal']
    @animals = ['spider','bear','rat']        
  end
  
  def teardown
    System.reset
  end  
  
  def test_to_literal
    assert(@teams.to_literal.kind_of?(Literal))
    assert_equal(@teams.length,@teams.to_literal.value.length)    
    assert_equal(@teams.first,@teams.to_literal.value.first.value)
    assert(@teams.to_literal.value.last.kind_of?(Literal))    
  end
  
  def test_to_declaration
    assert_equal(true,@animals.to_declaration.kind_of?(LiteralDeclaration))
    #assert_equal('["spider", "bear", "rat"]',@animals.to_declaration.write)
  end
  
  def test_contains?
    
    # Check that contains? searches go through each of the elements
    results = [[].to_var,7.to_var]
    assert(results.contains? {|x| x.kind_of?(ArrayVariable)})
    assert(results.contains? {|x| x.kind_of?(FixnumVariable)})
    assert_equal(false,results.contains? {|x| x.kind_of?(StringVariable)})    
    
  end
  
  def test_in_tandem
    
    letters = ('A'..'C').to_a
    numbers = (1..3).to_a
    container = []
    letters.zip(numbers) do |x,y|
      container.push(x+y.to_s)
    end
    assert_equal('A1',container.first)
    assert_equal('B2',container[1])
    assert_equal('C3',container.last)
    
  end
  
  def test_to_var
    assert_equal(5,['A','B','C'].to_var(5,10).variable_id)  
    assert_equal(10,['A','B','C'].to_var(5,10).uniq_id)      
  end
  
  def test_select_all_with_simple_structure
     assert_equal(5,['A',['B','C'],'D'].select_all {|x| true }.length)
  end
 
  def test_select_all_with_class_match
    assert_equal(4,['A',['B','C'],'D'].select_all {|x| x.kind_of?(String) }.length)
  end
  
end
