$LOAD_PATH << File.expand_path('../../../../../lib',__FILE__)

require 'required'
require 'test/unit'

class TestOpenStatement < Test::Unit::TestCase
  
  def setup  
    
    # Create a simple open if statement
    @simple_if_statement_var = Unknown.new
    simple_if_statement = Statement.new(If.new,Container.new(@simple_if_statement_var,Equivalent.new,'Stobart'.to_literal))
    @simple_open_if_statement = OpenStatement.new(simple_if_statement)
    
    # Create a simple open statement with variables
    @simple_open_statement_with_theory_variables = StringToTheory.run("if(var1 == 8)\nend")
    @simple_open_statement_with_theory_variables.push StringToTheory.run("var2 = var1.length")
    
    # More complex open statement with theory variables
    @open_theory_statement_two = StringToTheory.run("if(var1.realise2(var3).params[0].value.length == var2.length)\nend")
    @open_theory_statement_two.push StringToTheory.run("var4 = var2.length")
    
  end
  
  def teardown
    System.reset
    RuntimeMethod.reset_global_id
  end  
  
  def test_initialize
  end
  
  def test_write  
    
    # Test the simple statement is written out properly
    assert_equal("if(#{@simple_if_statement_var.write} == 'Stobart')\nend" ,@simple_open_if_statement.write)
    
    # Test that internal statements are properly tabs
    @simple_open_if_statement << Statement.new(Return.new,True.new)
    assert_equal("if(#{@simple_if_statement_var.write} == 'Stobart')\n\treturn true\nend" ,@simple_open_if_statement.write)
    
  end
  
  def test_select_all_with_theory_variables
    assert_equal(3,@simple_open_statement_with_theory_variables.select_all {|x| x.kind_of?(TheoryVariable)}.length)
    @simple_open_statement_with_theory_variables.select_all {|x| x.kind_of?(TheoryVariable)}.each do |x|
      assert(x.kind_of?(TheoryVariable))
    end
  end
  
  def test_select_all_with_open_theory_statement_two
    assert_equal(5,@open_theory_statement_two.select_all {|x| x.kind_of?(TheoryVariable)}.length)
  end
  
  def test_copy
    
    # Test copy with an open theory statement
    # TODO  This is quite a good way to test copy - I should use it across the other main classes
    initial_theory = StringToTheory.run("if(var1.length = var2.length)\nend")
    # => TODO uniq shouldn't be needed - why is it selecting the same value 
    original_element_ids = initial_theory.select_all{true}.collect {|x| x.object_id}.uniq
    
    copied_theory = initial_theory.copy
    copied_elements_ids = copied_theory.select_all{true}.collect {|x| x.object_id}.uniq

    assert_equal(
      original_element_ids.length*2,
      (copied_elements_ids + original_element_ids).uniq.length
    )
  end
  
  def test_write_structure_with_simple_examples
    assert_equal("if(a == b)\nend",Parser.run("if(var1 == var2)\nend").write_structure)
    assert_equal("if(a == b)\n\treturn c\nend",Parser.run("if(var1 == var2)\nreturn 8\nend").write_structure)
    assert_equal("if(a.chop == b)\n\treturn c\nend",Parser.run("if(var1.chop == var2)\nreturn 8\nend").write_structure)
    assert_equal("if(a.chop == b)\n\treturn a.chop\nend", Parser.run("if(var1.chop == var2)\nreturn var1.chop\nend").write_structure)
  end    
      
end