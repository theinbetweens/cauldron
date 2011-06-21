require 'required'
require 'test/unit'

class TestMethod < Test::Unit::TestCase
  
  def setup

    # Creates the statement to be inlcuded in the method
    @declaration_statement = DeclarationStatement.new(Unknown.new,Equal.new,Literal.new(8))      
    
    # Create the usage for the simple method (it doesn't take any parameters
    @simple_method_usage = MethodUsage.new()
    
    # Create the simple runtime method
    @simple_method = RuntimeMethod.new(@simple_method_usage,0)
    
    # Create the usage for a method with two paramters
    param_1 = MethodParameter.new
    @parameter_method_usage = MethodUsage.new(param_1)
    
    # Create the method with paramaters
    @method_with_paramaters = RuntimeMethod.new(@parameter_method_usage)
        
  end
  
  def teardown
    System.reset
    RuntimeMethod.reset_global_id    
  end
  
  def test_simple_statement_inclusion  
        
    # Test statement is valid
    assert_equal(true,@declaration_statement.valid_syntax?) 
    
    # Test the method is empty
    assert_equal(0,@simple_method.length)
    
    # Test the output of the written method
    file_dump = ""
    f = File.open($LOC+File.join(['test','output','simple_method.txt']),'r')
    f.each_line do |l|
      file_dump << l
    end
    f.close()  

    assert_equal(file_dump,@simple_method.write)
    
    # Add the statement to the method
    # assert_nothing_raised() {@simple_method.consider @declaration_statement}
    
    # Retrieve the possible methods that could use the @declaration_statement
    # possible_methods = @simple_method.consider @declaration_statement
    
    # Confirm that there is only one possible method
    # assert_equal(1,possible_methods.length)
    
    # Confirm that a runtime method was returned
    # assert_equal(true,possible_methods.first.kind_of?(RuntimeMethod),'Error: Expected RuntimeMethod class')
    
#    new_file_dump = ""
#    f = File.open($LOC+File.join(['test','output','test_method','first_possible_method.txt']),'r')
#    f.each_line do |l|
#      new_file_dump << l
#    end
#    f.close()
#    assert_equal(new_file_dump,possible_methods.first.write)
    
  end
  
  def test_method_copy
  
    # Create the usage for a method with a parameter
    param_1 = MethodParameter.new()
    parameter_method_usage = MethodUsage.new(param_1)    
    
    # Create the method 
    original_method = RuntimeMethod.new(parameter_method_usage)
    
    # Add parameters to the method
    param_values = MethodParameter.new
    #original_method.parameters = [param_values]
    
    # Check the number of paramaters
    #assert_equal(1,original_method.parameters.length)
    
    # Copy the method
    assert_nothing_raised(){copied_method = original_method.copy}
    copied_method = original_method.copy
    
    # Confirm class of copied method
    assert_equal(true,copied_method.class==RuntimeMethod)
    
    # Check that the correct number of parameters were copied
    #assert_equal(original_method.parameters.length,copied_method.parameters.length)
    
  end
  
  def test_statement_inclusion_with_not_declared_variables
    
    # Test the method is empty
    assert_equal(0,@method_with_paramaters.length)          
    
    # Create the statement with unknown variables in them
    chop_statement = DeclarationStatement.new(Unknown.new,Equal.new,InstanceCallContainer.new(Unknown.new,Chop.new))
    assert_equal(false,chop_statement.valid_syntax?)
    
    # Test the number of paramaters
    #assert_equal(1,@method_with_paramaters.parameters.length)
    
    # Check the paramters description
    #assert_equal("var_4\t\t= 'test'\n",@method_with_paramaters.parameters.first.describe)
    
    # Retrieve the two possible methods  
    #possible_methods = @method_with_paramaters.consider chop_statement
    
#    # Confirm that an array of results was returned
#    assert_equal(true,possible_methods.class == Array)
#    
#    # Confirm the total number of results
#    assert_equal(1,possible_methods.length)
#    
#    # Check the data type of all the returned methods
#    possible_methods.each do |m|
#      assert_equal(true,m.class == RuntimeMethod)
#    end
      
  end
  
end