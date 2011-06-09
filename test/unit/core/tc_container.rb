require 'required'
require 'test/unit'

class TestContainer < Test::Unit::TestCase
  
  def setup
    @simple_container = Container.new(Parser.run('var3'),Equivalent.new,Parser.run('var2'))          
  end
  
  def teardown
    System.reset
    RuntimeMethod.reset_global_id    
  end
  
  def test_initialize
    Container.new(
      Parser.run('var3'),
      Equivalent.new,
      Parser.run('var2')
    )    
  end
  
  def test_write
    assert_equal(
        Container.new(
          Parser.run('var3'),
          Equivalent.new,
          Parser.run('var2')
        ).write,
        '(var_3 == var_2)'
    )
  end  
  
  def test_select_all
    assert_equal(
      2,
      @simple_container.select_all {|x| x.kind_of?(BaseVariable)}.length
    )
  end    
   
end