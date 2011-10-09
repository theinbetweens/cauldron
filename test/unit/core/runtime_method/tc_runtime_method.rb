$LOAD_PATH << File.expand_path('../../../../../lib',__FILE__)

require 'cauldron'
require 'test/unit'

class TestRuntimeMethod < Test::Unit::TestCase
  
  def setup
    
    # Create the method usage 
    @method_var_a = MethodParameter.new
    # Not used in the method
    @method_var_b = MethodParameter.new
    @single_parameter_usage = MethodUsage.new(@method_var_a,@method_var_b)
    
    # Create the simple method used in the tests
    @simple_method = RuntimeMethod.new(@single_parameter_usage)
    
    # Add a few simple statements to the method
    @var_b = Unknown.new
    @statement_a = Statement.new(@var_b,Equal.new,Literal.new(9))
    @var_c = Unknown.new
    @statement_b = Statement.new(@var_c,Equal.new,InstanceCallContainer.new(@method_var_a,Chop.new))
    @var_d = Unknown.new
    @statement_c = Statement.new(@var_d,Equal.new,InstanceCallContainer.new(@var_c,StringLength.new))
    @var_e = Unknown.new
    @var_f = Unknown.new
    @statement_d = Statement.new(@var_e,Equal.new,@var_b,Addition.new,@var_d)
    @simple_method.push(@statement_a)
    @simple_method.push(@statement_b)
    @simple_method.push(@statement_c)    
    @simple_method.push(@statement_d)    
    @simple_method.push(Statement.new(@var_f,Equal.new,InstanceCallContainer.new(@var_c,StringLength.new)))        
    
    # Create a runtime method with no parameters
    @method_b = RuntimeMethod.new(MethodUsage.new)
    
    # Create a method that accepts one string parameter and some string parameters to use
    @method_c = RuntimeMethod.new(MethodUsage.new(MethodParameter.new))
    @var_g = 'Monkey'.to_var
    @var_h = 'Island'.to_var   
    @var_i = '3'.to_var
    
    # The methods all return string variables and have an increasing number of parameters
    @method_usage_var_a = 'a string'.to_var
    @method_respnse_a = 'Mass Effect'.to_var
    @method_d = RuntimeMethod.new(MethodUsage.new(),@method_respnse_a)
    
    # Create a method that excepts two string parameters
    @method_usage_var_b = MethodParameter.new()
    @method_usage_var_c = MethodParameter.new()
    @method_e = RuntimeMethod.new(MethodUsage.new(@method_usage_var_b,@method_usage_var_c))
    
    @method_usage_var_e = MethodParameter.new()
    @method_usage_var_f = MethodParameter.new()
    @method_respnse_b = 'Halo'.to_var
    @method_f = RuntimeMethod.new(MethodUsage.new(@method_usage_var_e,@method_usage_var_f),@method_respnse_b)
    
    # Create the methods to test the runtime methods history call    
    # Simple example
    # def method_0
    #   var_0 = 'Civilisation'
    #   var_1 = var_0.length
    # end
    @method_history_a = RuntimeMethod.new(MethodUsage.new)
    @var_j = Unknown.new
    @method_history_a.push( Statement.new(@var_j,Equal.new,Literal.new('Civilisation')) )
    @method_history_a.push( Statement.new(Unknown.new,Equal.new,InstanceCallContainer.new(@var_j,StringLength.new)) )    
    
    # Create a runtime method that use nested statements
    # var_0 = ''
    # var_1 = 'x'
    # 3.times do |var_2|
    #   var_0 = var_0 + var_1
    # end
    #
    @build_xxx_method = RuntimeMethod.new(MethodUsage.new)    
    @blank_variable = Unknown.new
    @x_variable = Unknown.new
    @build_xxx_method.push( Statement.new(@blank_variable,Equal.new,Literal.new('')) )
    @build_xxx_method.push( Statement.new(@x_variable,Equal.new,Literal.new('x')) )
    nested_xxx_statement = BlockStatement.new( Statement.new(InstanceCallContainer.new(Literal.new(3),Times.new)) )
    nested_xxx_statement.push(Statement.new(@blank_variable,Equal.new,@blank_variable,Addition.new,@x_variable) )
    @build_xxx_method.push( nested_xxx_statement )
    
    # Create a method that calls a different method
    @called_method = RuntimeMethod.new(MethodUsage.new)
    @called_method << Statement.new(Return.new,' Jelly'.to_literal)
    
    # Create an empty runtime method
    @empty_rumtime_method = RuntimeMethod.new(MethodUsage.new(MethodParameter.new,MethodParameter.new))
    
  end
  
  def teardown
    System.reset
  end  
  
  def test_copy
    
    # Test some basic runtime method instances
    assert_equal(@statement_d.write,@statement_d.copy.write)
    assert_equal(@statement_d.write_with_uniq_id,@statement_d.copy.write_with_uniq_id)    
    assert_equal(@build_xxx_method.write,@build_xxx_method.copy.write)
    assert_equal(@build_xxx_method.write_with_uniq_id,@build_xxx_method.copy.write_with_uniq_id)    

    #  Check that dependies are found for modified statements
    #   var_a = 8
    #   var_b = []
    #   var_b.push(9)
    #   var_b.push(10)
    statement_a_1 = Statement.new(Unknown.new,Equal.new,8.to_literal)
    statement_a_2 = Statement.new(Unknown.new,Equal.new,[].to_literal)    
    statement_a_3 = Statement.new(InstanceCallContainer.new(statement_a_2.first.copy,Push.new,9.to_literal))
    statement_a_4 = Statement.new(InstanceCallContainer.new(statement_a_3.first.subject.copy,Push.new,10.to_literal))
    runtime_a = RuntimeMethod.new(MethodUsage.new)
    runtime_a.push(statement_a_1)
    runtime_a.push(statement_a_2)
    runtime_a.push(statement_a_3)
    runtime_a.push(statement_a_4)
    assert_equal(runtime_a.write,runtime_a.copy.write)
    assert_equal(runtime_a.write_with_uniq_id,runtime_a.copy.write_with_uniq_id)    
    
    
  end
  
  def test_statement_count
    assert_equal(5,@simple_method.statement_count)
    assert_equal(0,@method_b.statement_count)
    assert_equal(5,@build_xxx_method.statement_count)
  end
  
  def test_partial_method
    
    # Retrieve a partial version of a runtime method and checks the length is correct
    assert_nothing_raised(){@simple_method.partial_method(3)}
    assert(@simple_method.partial_method(3).kind_of?(RuntimeMethod))
    assert(4,@simple_method.partial_method(4).length)
    
    # Attempt to retrieve a bigger method
    assert_raises(MethodSizeError){@simple_method.partial_method(@simple_method.length+1)}
    
    # Retrieve a partial for a method with nested statements
    assert_nothing_raised(){@build_xxx_method.partial_method(3)}        
    
  end
  
  # Tests the method that retrieves all the variables from a particular
  # method.  The variables aren't in the context of the method.
  #
  def test_available_variables
    
    # Check the correct number of variables are returned
    var_count = 7
    assert_equal(var_count,@simple_method.available_variables(ParametersContainer.new(@method_var_a,@method_var_b)).length)
    
    # Check its in the expected order
    assert_equal(@var_f.variable_id,@simple_method.available_variables(ParametersContainer.new(@method_var_a,@method_var_b)).last.variable_id)
    
    # Add a dupplicate statement to method and check there are the same number of variables
    @simple_method.push(@statement_a)
    assert_equal(var_count,@simple_method.available_variables(ParametersContainer.new(@method_var_a,@method_var_b)).length)    
    
  end
  
  # Tests the RuntimeMethods abilitity to identify what comninations
  # of variables can be used to call this method.
  #
  def test_callable_combinations
    
    # Assert that a method with no parameters only has one call
    assert_equal(1,@method_b.callable_combinations([]).length)
    assert(@method_b.callable_combinations([]).last.kind_of?(DefCall))
    
    # Check the number of methods calls available when only using variables
    assert_equal(3,@method_c.callable_combinations([@var_g,@var_h,@var_i]).length)
    assert(@method_c.callable_combinations([@var_g,@var_h,@var_i]).last.kind_of?(DefCall))    
    
    # Check a combination of method calls and runtime methods
    assert_equal(3,@method_c.callable_combinations([@var_g,@var_h,@var_i]).length)         
    
    # Check using a method that allows muliple parameters
    assert_equal(9,@method_e.callable_combinations([@var_g,@var_h,@var_i]).length)                      

  end
  
  # TODO  Need to test with methods that require parameters (var_a) etc
  def test_history                                      
    assert_equal(2,@method_history_a.history(ParametersContainer.new)[2]['variables'].length)                                            
    assert_equal("'Civilisation'",@method_history_a.history(ParametersContainer.new)[1]['variables'].first['value'].write)                      
    assert_equal("12",@method_history_a.history(ParametersContainer.new)[2]['variables'].first['value'].write)                                
    assert_equal("'Civilisation'",@method_history_a.history(ParametersContainer.new)[2]['variables'].last['value'].write)
    
    # Check that history retains the correct variable ids
    manny = 'Manny'.to_var
    string_runtime_method = RuntimeMethod.new(MethodUsage.new(),nil)   
    
    # Add a statement to the runtime method
    manny_length_var = Unknown.new
    
    a_equals_manny_length = Statement.new(manny_length_var,Equal.new,InstanceCallContainer.new(manny,StringLength.new))
    string_runtime_method.push(a_equals_manny_length)    
    
    # Check that the unknown variable "manny_length_var" retains the correct id
    assert_nothing_raised() {string_runtime_method.find_variable(manny_length_var.variable_id)}    
    
    # Check that history captures all the expected values.
    @method_history_a.history(ParametersContainer.new)[1]['variables'].each do |x|
      assert_not_nil(x['id'])
      assert_not_nil(x['uniq_id'])
    end
          
  end
  
  #      def method_0(var1)
  #        if(var1=='something')
  #          return 'exists'
  #        end
  #        return 'does not exist'
  #      end
  #      
  def test_history_case_1
    
    # Create the runtime that's history will be checked
    param1 = MethodParameter.new
    rm = RuntimeMethod.new(MethodUsage.new(param1))
    statement1 = Parser.run("if(#{param1.write}=='something')\nend")
    statement1 << Parser.run("return 'exists'")
    rm << statement1
    rm << Parser.run("return 'does not exists'")
    
    assert_nothing_raised(){rm.history2(['akfjlkasd'])}
    assert_equal(2,rm.history2(['akfjlkasd']).length)
    assert_equal(2,rm.history2(['something']).length)
    # TODO  Should check what I think statement_id values are are correct
    
  end
  
  def test_trackify
    
    # Create a simple method to be trackified
    manny = MethodParameter.new()
    string_runtime_method = RuntimeMethod.new(MethodUsage.new(manny),nil)
    
    # Add a statement to the runtime method
    manny_length_var = Unknown.new
    a_equals_manny_length = Statement.new(manny_length_var,Equal.new,InstanceCallContainer.new(manny,StringLength.new))
    string_runtime_method.push(a_equals_manny_length)    
    
    # Save the original written method
    original_written = string_runtime_method.write
    
    # Create the method that changes are logged to
    instance_tracking_variable = ArrayVariable.new
    instance_tracking_variable.instance_variable = true
    tracking_method = RuntimeTrackingMethod.new(instance_tracking_variable)    

    # Trackify it and check nothing is raised
    assert_nothing_raised(){
      string_runtime_method.trackify(ParametersContainer.new('Manny'.to_var),tracking_method)
    }

    # Check that the method is unchanged after trackify
    assert_equal(original_written,string_runtime_method.write)    
        
  end
  
  def test_realise_with_an_empty_runtime_method
    
    # Check that parameters have the same variable id
    assert_not_nil(@empty_rumtime_method.usage[0].variable_id)
    assert_not_nil(@empty_rumtime_method.realise2(['Mia','Elle']).params[0].variable_id)
    assert_equal(
      @empty_rumtime_method.usage[0].variable_id,
      @empty_rumtime_method.realise2(['Mia','Elle']).params[0].variable_id
    )
    
  end
  
  # Checks that a relised method only contrains literal values
  # and type variables.  Each of the type variables should contain
  # there own literal value.
  # 
  # TODO  Test this nested statements and with variable overwritting.
  # 
  # TODO  When I start to use variable overwriting I need to come up with 
  #       a way of identifying equivalence.
  # 
  #       e.g. 
  #       var_a = 'test'
  #       var_b = var_a.length
  #   
  #       and
  #     
  #       var_a = 'test'
  #       var_a = var_a.length
  # 
  #       In this situation var_a is the same as var_b.  Asides from removing the 
  #       availablility of 'var_a'test'.  
  #       
  #       Actually it really boils down to creating new variables.  So as long as 
  #       var_a isn't used the overwrite doesn't matter.  I do need keep track of 
  #       variations of a variable e.g. var_a(0) var_a(1).  The variations are 
  #       essential variables in their own right.
  # 
  def test_realise
    
    # Create a simple runtime method and check that the paramaters are valid
    var_a = MethodParameter.new
    var_b = MethodParameter.new        
    var_g = MethodParameter.new
    simple_method = RuntimeMethod.new(MethodUsage.new(var_a,var_b,var_g))
    
    # Check that realise returns an identical runtime method
    var_a_value = StringVariable.new('Grim')    
    var_b_value = 'fandango'.to_var
    var_g_value = 'Threepwood'.to_var
    assert_nothing_raised(){
      simple_method.realise2(['Grim','fandango','Threepwood'])
    }
    realised_instance_1 = simple_method.realise2(['Grim','fandango','Threepwood'])
    assert_equal(
      "\n#\n#  @param  [StringVariable] 'Grim'\n#  @param  [StringVariable] 'fandango'\n" \
      "#  @param  [StringVariable] 'Threepwood'\n#\n#\n" \
      "def method_0(var_#{simple_method.usage[0].variable_id}, var_#{simple_method.usage[1].variable_id}, var_#{simple_method.usage[2].variable_id})\n\nend\n",
      realised_instance_1.write
    )
    
    # Check that all the variables are type variables and have a literal value
    realised_instance_1.available_variables(ParametersContainer.new(var_a_value,var_b_value,var_g_value)).each do |x|
      assert(x.kind_of?(TypeVariable))      
    end
    assert(realised_instance_1.available_variables(ParametersContainer.new(var_a_value,var_b_value,var_g_value)).any? {|x| x.value == 'Grim' })
    assert(realised_instance_1.available_variables(ParametersContainer.new(var_a_value,var_b_value,var_g_value)).any? {|x| x.value == 'fandango' })
    assert_not_equal(true,realised_instance_1.available_variables(ParametersContainer.new(var_a_value,var_b_value,var_g_value)).any? {|x| x.value == 'WARREN' })
    
    # Check that invalid paramters and undeclared parameters are caught
    temp_method = RuntimeMethod.new(MethodUsage.new(MethodParameter.new))
    assert_raises(StandardError) {temp_method.realise2([])}
    
    # Now let's add a few statements to the method
    # var_c = var_a.length
    var_c = Unknown.new
    simple_method.push(Statement.new(var_c,Equal.new,InstanceCallContainer.new(var_a,StringLength.new)))
    realised_instance_2 = simple_method.realise2(['Grim','fandango','Threepwood'])
    assert_equal(
      "\n#\n#  @param  [StringVariable] 'Grim'\n#  @param  [StringVariable] 'fandango'\n#  @param  [StringVariable] 'Threepwood'\n#\n#\n"\
      "def method_0(var_#{simple_method.usage[0].variable_id}, var_#{simple_method.usage[1].variable_id}, var_#{simple_method.usage[2].variable_id})"\
      "\n  var_64 = var_35.length\nend\n",
      realised_instance_2.write
    )
    
    # Now lets have a chop instance call as well
    # var_d = var_a.chop
    simple_method.push(Statement.new(Unknown.new,Equal.new,InstanceCallContainer.new(var_a,Chop.new)))
    simple_method_written_3 = simple_method.write
    realised_simple_method_3 = simple_method.realise2(['Grim','fandango','Threepwood'])
    assert_equal(
      "\n#\n#  @param  [StringVariable] 'Grim'\n"\
      "#  @param  [StringVariable] 'fandango'\n"\
      "#  @param  [StringVariable] 'Threepwood'\n"\
      "#\n#\ndef method_0(var_#{simple_method.usage[0].variable_id}, var_#{simple_method.usage[1].variable_id}, var_#{simple_method.usage[2].variable_id})\n"\
      "  var_64 = var_#{simple_method.usage[0].variable_id}.length\n  var_76 = var_#{simple_method.usage[0].variable_id}.chop\nend\n",
      realised_simple_method_3.write
    )
    
    # Go through each statement and check that there are no unrealised values
    realised_simple_method_3.each do |x|
      assert_equal(0,x.unrealised_variables.length)
    end
    
    # Try adding a variable that gets defined in a previous statement
    # var_e = var_b.length
    # var_f = var_e+var_c
    var_e = Unknown.new
    var_f = Unknown.new()
    simple_method.push(Statement.new(var_e,Equal.new,InstanceCallContainer.new(var_b,StringLength.new)))
    simple_method.push(Statement.new(var_f,Equal.new,var_e,Addition.new,var_c))
    simple_method_written_4 = simple_method.write
    realised_simple_method_4 = simple_method.realise2(['Grim','fandango','Threepwood'])
    assert_equal(
      "\n#\n#  @param  [StringVariable] 'Grim'\n#  @param  [StringVariable] 'fandango'\n#  @param  [StringVariable] 'Threepwood'\n#\n#\ndef method_0(var_35, var_36, var_37)\n  var_64 = var_35.length\n  var_76 = var_35.chop\n  var_89 = var_36.length\n  var_90 = var_89 + var_64\nend\n",
      realised_simple_method_4.write
    )
    
    # Go through and check that there are no unrealised_variables 
    realised_simple_method_4.each do |x|
      assert_equal(0,x.unrealised_variables.length)
    end    

    # Check that a array variable can be realised
    var_h = Unknown.new
    simple_method.push(Statement.new(var_h,Equal.new,InstanceCallContainer.new(var_g,ArrayLength.new)))
    
    # Check that a block statement can be used
    nested_statement = BlockStatement.new(Statement.new(InstanceCallContainer.new(var_h,Times.new)))
    nested_statement.push Statement.new(var_e,Equal.new,var_e,Addition.new,var_f)
    simple_method.push(nested_statement)
    
    # 2#  Try relising a method that declares a value via another method call  
    #     e.g. a method with the statement 'var = method_45'
    
    # a.  Create the method that returns a statement variable
    return_statement_method = RuntimeMethod.new(MethodUsage.new(),Statement.new.to_var)
    return_statement_method.push(Parser.run('return Statement.new(Return.new,"sparky")'))
    
    # b.  Create the method 
    runtime_method_2 = RuntimeMethod.new(MethodUsage.new)    
    declared_variable = Unknown.new
    runtime_method_2.push( Statement.new(declared_variable,Equal.new,DefCall.new(Statement.new.to_var,return_statement_method)))
    
    # c.  Check that the method can't be relised with the called runtime method
    assert_raises(StandardError) {runtime_method_2.realise2(ParametersContainer.new)}
    
    # d.  Check that the unknow variable has been converted into a StatementVariable
    assert_nothing_raised() {runtime_method_2.realise2(ParametersContainer.new,[return_statement_method])}
    assert(runtime_method_2.realise2(ParametersContainer.new,[return_statement_method]).kind_of?(RealisedRuntimeMethod))
    realised_runtime_method_2 = runtime_method_2.realise2(ParametersContainer.new,[return_statement_method])
    assert_equal(false,realised_runtime_method_2.find_variable(declared_variable.variable_id).kind_of?(Unknown))
      
    # Check that value of last variable after it has been realised
    
    # NEXT Use method calls 
    
  end
  
  # Test that the runtime methods are written properly.  
  #
  def test_write

    # Create a simple method with no paramaters
    method_example_a = RuntimeMethod.new(MethodUsage.new)       
    assert_equal("\n#\n#\ndef method_#{method_example_a.method_id.to_s}\nend\n",method_example_a.write(nil))
    
    # Test a simple method with one paramter
    #param_1 = StringVariable.new('Girm')
    param_1 = MethodParameter.new
    method_example_b = RuntimeMethod.new(MethodUsage.new(param_1))
    assert_not_equal("#\n#\ndef method_"+method_example_b.method_id.to_s+"\n\nend\n",method_example_b.write)    
      
    # Test that neested methods are writen properly      
    assert_equal("\n#\n#\ndef method_6\n  var_28 = ''\n  var_29 = 'x'\n  3.times do |var_30|\n    var_28 = var_28 + var_29\n  end\n\nend\n",@build_xxx_method.write)  
    
    # Test how the method is written with tabs
    assert_equal("\n  #\n  #\n  def method_6\n    var_28 = ''\n    var_29 = 'x'\n    3.times do |var_30|\n      var_28 = var_28 + var_29\n    end\n\n  end\n",@build_xxx_method.write(nil,1))      
         
  end
  
  def test_push
    
    # Create a method that is passed a string
    #manny = 'Manny'.to_var
    manny = MethodParameter.new
    string_runtime_method = RuntimeMethod.new(MethodUsage.new(manny),nil)    
    
    manny_length_var = Unknown.new
    a_equals_manny_length = Statement.new(manny_length_var,Equal.new,InstanceCallContainer.new(manny_length_var,StringLength.new))
    string_runtime_method.push(a_equals_manny_length)
    
    # Check that the variable ids are equal
    assert_nothing_raised(){string_runtime_method.find_variable(manny_length_var.variable_id)}

  end
   
  def test_identify_overriding_statements

    # Create a method that is passed a string
    manny = 'Manny'.to_var
    # def method_0(var_a)
    #   var_b = var_a.length
    #   var_b.times do |var_c|
    #     var_a = 'Glotis'
    #   end
    # end
    string_runtime_method = RuntimeMethod.new(
      MethodUsage.new(MethodParameter.new),nil
    )
    
    manny_length_var = Unknown.new
    a_equals_manny_length = Statement.new(manny_length_var,Equal.new,InstanceCallContainer.new(manny,StringLength.new))
    string_runtime_method.push(a_equals_manny_length)    
    
    # Add the first nested statement to the method.
    manny_length_times = Statement.new(InstanceCallContainer.new(manny_length_var,Times.new))
    manny_length_times_do = BlockStatement.new(manny_length_times)     
    
    # Override manny with a new string
    overriding_statement = Statement.new(manny,Equal.new,Literal.new('Glotis'))
    manny_length_times_do.push( overriding_statement )
    string_runtime_method.push(manny_length_times_do)         
    
    # Identify all the overridden statements
    assert_nothing_raised() {string_runtime_method.identify_overriding_statements(ParametersContainer.new(manny))}
    assert_equal(false,string_runtime_method.find_statement(a_equals_manny_length.statement_id).overrides?)
    assert_equal(true,string_runtime_method.find_statement(overriding_statement.statement_id).overrides?)    
    
  end
  
  def test_to_var
    assert(@simple_method.to_var.kind_of?(RuntimeMethodParameter))
    
    # Declare the runtime method variable and check it retains the properties of
    # the original runtime method.
    simple_method_var = @simple_method.to_var
    
    # Check the statements are retained
    assert_equal(@simple_method.length,simple_method_var.value.length)
    assert_equal(@simple_method.method_id,simple_method_var.value.method_id)        
    
    # Check that variable ids can be set
    assert_equal(8,@simple_method.to_var(8,9).variable_id)
    assert_equal(9,@simple_method.to_var(8,9).uniq_id)    
    
  end

  def test_abstract_variables_for_tracking_with_some_simple_statement
    #assert_equal(1,@simple_method.abstract_variables_for_tracking(Parser.run('var4 = "test"')).length)
    # TODO  The parser doesn't generate a variable with an id of 7 here - is that a problem?
    assert_equal(2,@simple_method.abstract_variables_for_tracking(Parser.run('var7 = var70.length')).length)
  end
  
  def test_all_pass_with_basic_method
    basic_method = RuntimeMethod.new(MethodUsage.new(MethodParameter.new()))
    basic_method.push(Parser.run('return var'+basic_method.usage.first.variable_id.to_s))
    test_cases = [
      {:params=>['sparky'], :output=>'sparky'},
      {:params=>['pip'], :output=>'pip'},
    ]
    assert_equal(true,basic_method.all_pass?(test_cases))
  end
  
  def test_pass_with_basic_method
    basic_method = RuntimeMethod.new(MethodUsage.new(MethodParameter.new()))
    basic_method.push(Parser.run('return var'+basic_method.usage.first.variable_id.to_s))
    assert_equal(true,basic_method.pass?({:params=>['sparky'], :output=>'sparky'}))
  end
  
  def test_pass_with_a_method_that_returns_an_integer
    basic_method = RuntimeMethod.new(MethodUsage.new(MethodParameter.new()))
    basic_method.push( 
      Parser.run("return var#{basic_method.usage.first.variable_id.to_s}.length")
    )
    assert_equal(true,basic_method.pass?({:params=>['sparky'], :output=>'sparky'.length}))
  end
        
end