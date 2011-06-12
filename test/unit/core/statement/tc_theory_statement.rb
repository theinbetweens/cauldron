$LOAD_PATH << File.expand_path('../../../../../lib',__FILE__)

require 'required'
require 'test/unit'

class TestTheoryStatement < Test::Unit::TestCase
  
  def setup
    @statement_1 = StringToTheory.run("var8 = 7")
  end
  
  def teardown
    System.reset
    RuntimeMethod.reset_global_id
  end  

  def test_copy
    assert(@statement_1.copy.kind_of?(TheoryStatement))
  end
  
  def test_select_all
    assert_equal(
      3,
      StringToTheory.run(
        'var1.realise2(var3).params[0].value.length == var2.length'
      ).select_all {|x| x.kind_of?(TheoryVariable)}.length
    )      
  end
  
  #   Using:
  #   if((var1.params[var3].length == var1) == false)
  #     return true
  #   end
  #
  def test_replace_theory_variables_with_case_1
    theory = TheoryStatement.new(
      StringToTheory.run("if((var1.params[var3].length == var1) == false)\nreturn true\nend")
    )
    
    # Create the intrinsic mapping for the theory
    mapping = Mapping.new
    mapping[1] = Parser.run('runtime_method')
    mapping[3] = IntrinsicLiteral.new(0)
    
    assert_equal(
      "if((runtime_method.params[0].length == runtime_method) == false)\n\treturn true\nend",
      theory.replace_theory_variables!(mapping).write
    )
    
    
  end
      
end