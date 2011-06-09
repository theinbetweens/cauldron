require 'required'
require 'test/unit'

class TestParser < Test::Unit::TestCase
  
  def setup
    
  end
  
  def teardown
    
  end
  
  def test_run_with_literal_number_conversion
    assert_equal('9',Parser.run('9').write)
    assert_not_equal('9',Parser.run('10').write)
  end
  
  def test_run_with_literal_string_conversion
    assert_equal("'test'",Parser.run("'test'").write)
    assert_equal("'10 million fireflies'",Parser.run("'10 million fireflies'").write)
  end
  
  def test_run_with_single_variable
    assert_equal('var_8',Parser.run('var8').write)
  end
  
  def test_run_with_a_instance_method_call
    assert_equal('var_8.length',Parser.run('var8.length').write)
    assert(Parser.run('var8.length').kind_of?(InstanceCallContainer))
  end
  
  def test_run_with_a_literal_method_call
    assert_equal("'new vegas'.length",Parser.run("'new vegas'.length").write)
  end
  
  def test_run_with_intrinsic_runtime_method
    assert_equal('runtime_method.params',Parser.run('runtime_method.params').write)
    assert_equal('runtime_method.params[0]',Parser.run('runtime_method.params[0]').write)
    assert_equal('test_cases[0]',Parser.run('test_cases[0]').write)
    assert_equal('test_cases[0][:output]',Parser.run('test_cases[0][:output]').write)
    assert_equal('test_cases[0].params[0]',Parser.run('test_cases[0].params[0]').write)
    assert_equal('runtime_method.params[0].value',Parser.run('runtime_method.params[0].value').write)
  end
  
  def test_run_with_array_elements
    assert_equal('var_6[8]',Parser.run('var6[8]').write)    
  end
  
  def test_run_with_return_statement
    assert_equal('return true',Parser.run('return true').write)
    assert_equal('Statement',Parser.run('return true').class.to_s)
  end
  
  def test_run_with_theory_result_1
    assert_equal(
      'runtime_method.all_pass?(test_cases)',
      Parser.run('runtime_method.all_pass?(test_cases)').write
    )      
  end
  
  def test_run_with_next
    assert_equal(
      'next',
      Parser.run('next').write
    )
  end
  
  def test_run_with_push
    assert_equal(
     'var_1.push(8)',
      Parser.run('var1.push(8)').write
    )    
  end    
  
  def test_run_adding_two_variables
    assert_equal(
     'var_1 = var_2 + var_3',
      Parser.run('var1 = var2 + var3').write
    )       
  end 
  
  def test_run_with_history_call
    assert_equal(
      'var_1.history(var_2)',
      Parser.run('var1.history(var2)').write
    )
  end    
  
  def test_run_with_a_populated_if_statement
    assert_equal(
      "if(runtime_method.all_pass?(test_cases))\nend",
      Parser.run("if(runtime_method.all_pass?(test_cases))\nend").write
    ) 
    assert_equal(
      "if(runtime_method.all_pass?(test_cases))\n\treturn true\nend",
      Parser.run("if(runtime_method.all_pass?(test_cases))\nreturn true\nend").write
    )
  end    
  
  def test_run_when_adding_a_number_and_fixnum
    assert_equal(
      "var_2 = var_5.chop + var_2",
      Parser.run("var2 = var5.chop + var2").write
    )
  end
  
end