$LOAD_PATH << File.expand_path('../../../../../lib',__FILE__)

require 'required'
require 'test/unit'

class TestBlockStatement < Test::Unit::TestCase
  
  def setup
  
    @games = ['Grim Fandango','Monkey Island', 'Full Throttle','Simon the Soreceror'].to_var
    @block_variable = BlockVariable.new
    @block_container = BlockContainer.new(@block_variable)
    @each_game = BlockStatement.new(
      Statement.new(InstanceCallContainer.new(@games,ArrayEach.new)),
      @block_container
     )
    @declared_unknown = Unknown.new
    @declare_six = Statement.new(@declared_unknown,Equal.new,Literal.new(6))
    @populated_loop_block_var = BlockVariable.new
    @populated_loop = BlockStatement.new( 
      Statement.new(InstanceCallContainer.new(@games,ArrayEach.new)),
      BlockContainer.new(@populated_loop_block_var),
      @declare_six 
    )
  
  end
  
  def teardown
    System.reset
    RuntimeMethod.reset_global_id
  end  
  
  def test_initialize
  end
  
  def test_write
    assert_equal("var_0.each do |var_"+@block_variable.variable_id.to_s+"|\nend\n",@each_game.write(0))    
    assert_equal("  var_0.each do |var_1|\n  end\n",@each_game.write(1))    
    assert_equal(
      "var_0.each do |var_"+@populated_loop_block_var.variable_id.to_s+"|\n  var_"+@declared_unknown.variable_id.to_s+" = 6\nend\n",
      @populated_loop.write(0)
    )    
    assert_equal(
      "  var_0.each do |var_"+@populated_loop_block_var.variable_id.to_s+"|\n    var_"+@declare_six.declared_variable_id.to_s+" = 6\n  end\n",
      @populated_loop.write(1)
    )        
  end
  
  def test_copy
    assert_equal(@each_game.write,@each_game.copy.write)    
  end
      
end