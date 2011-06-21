$LOAD_PATH << File.expand_path('../../../../../lib',__FILE__)

require 'required'
require 'test/unit'

class TestHistory < Test::Unit::TestCase
  
  def setup
    
    # Create the initial runtime method instance for testing
    @simple_runtime_method = RuntimeMethod.new(MethodUsage.new,nil.to_var)        
    
    # Create a method that is passed a string
    @grim_fandango_method_var = MethodParameter.new
    @grim_fandango = 'Grim Fandango'.to_var(@grim_fandango_method_var.variable_id)
    @string_runtime_method = RuntimeMethod.new(MethodUsage.new(@grim_fandango_method_var),nil)
        
  end
  
  def teardown
    System.reset
    RuntimeMethod.reset_global_id
  end  
  
  def test_initialize
    
  end
  
  def test_find_steps_with_variable

    # Add 'var_b = var_a.chop'
    b_equals_A_chop = Statement.new(Unknown.new,Equal.new,InstanceCallContainer.new(@grim_fandango_method_var,Chop.new))    
    @string_runtime_method.push(b_equals_A_chop)
    assert_equal(
      2,
      @string_runtime_method.history([@grim_fandango]).find_steps_with_variable(
        @grim_fandango_method_var.variable_id
      ).length
    )
    assert_equal(1,@string_runtime_method.history(ParametersContainer.new(@grim_fandango)).find_steps_with_variable(b_equals_A_chop.declared_variable_id).length)    
    
  end

# ================= CUSTOM ====================

  def test_history_call_through_runtime_method
    
    # Check that a essentially empty history object is returned
    assert(@simple_runtime_method.history(ParametersContainer.new).kind_of?(History))
    
    # Check that a runtime method that includes a string returns properly
    assert(@string_runtime_method.history(ParametersContainer.new(@grim_fandango)).kind_of?(History))
    assert_equal(1,@string_runtime_method.history(ParametersContainer.new(@grim_fandango)).length)
    
    # Add 'var_b = var_a.chop'
    b = Unknown.new
    b_equals_A_chop = Statement.new(b,Equal.new,InstanceCallContainer.new(@grim_fandango_method_var,Chop.new))
    @string_runtime_method.push(b_equals_A_chop)
    after_one_statement = @string_runtime_method.history(ParametersContainer.new(@grim_fandango))
    assert_equal(2,after_one_statement.length)
    
    # Check that the correct number of variables are retained at each stage  
    assert_equal(1,after_one_statement[0]['variables'].length)
    assert_equal(2,after_one_statement[1]['variables'].length)    
    
    # Check that the variable has the correct id
    assert_equal(true,after_one_statement[1]['variables'].any? {|x| x['id']== b_equals_A_chop.declared_variable_id})
    
    # Confirm that all the saved variables have the correct ids
    found_steps = after_one_statement.find_steps_with_variable(@grim_fandango.variable_id)
    found_steps.each do |x|
      found_steps.each do |y| 
        assert_equal(x.find_data_for_variable(@grim_fandango.variable_id)['abs_id'],y.find_data_for_variable(@grim_fandango.variable_id)['abs_id'])  
      end
    end    
    
    # Add a length statement
    c = Unknown.new
    c_equals_a_length = Statement.new(c,Equal.new,InstanceCallContainer.new(b,StringLength.new))
    @string_runtime_method.push(c_equals_a_length)
    
    # Confirm that there are now 3 steps in the history
    assert_equal(3,@string_runtime_method.history(ParametersContainer.new(@grim_fandango)).length)
    
    # Add the first nested statement to the method.
    c_times = Statement.new(InstanceCallContainer.new(c,Times.new))
    c_time_do = BlockStatement.new(c_times)     
    @string_runtime_method.push(c_time_do)     

    # Confirm that each part of the statement is tracked
    assert_equal(16,@string_runtime_method.history(ParametersContainer.new(@grim_fandango)).length) 
    
  end
  
  def test_history_call_through_runtime_method_using_complex_method      
        
    # Add a length statement
    c = Unknown.new
    c_equals_a_length = Statement.new(c,Equal.new,InstanceCallContainer.new(@grim_fandango,StringLength.new))
    @string_runtime_method.push(c_equals_a_length)
    
  end
      
end