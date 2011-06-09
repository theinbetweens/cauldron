require 'required'
require 'test/unit'

class TestMethodValidation < Test::Unit::TestCase
  
  def setup
  end
  
  def teardown
    System.reset
    RuntimeMethod.reset_global_id
  end  

  def test_self_generate
    
    # Check that a simple method to check the class of a runtime method instance can be created
    validation_test_1 = MethodValidation.generate_attribute_test('.class.to_s == "RuntimeMethod"' )
    assert(validation_test_1.kind_of?(RuntimeMethod))   
    assert_equal(
      true,
      MethodValidation.new.use_runtime_method(
        validation_test_1,ParametersContainer.new(RuntimeMethod.new(MethodUsage.new).to_declaration)
      )
    )
    
    # Create the method that should be evaluated correctly
    test_2_method = RuntimeMethod.new(MethodUsage.new)
    test_2_method.push Statement.new(Return.new,'Lilly'.to_literal)

    # Test that a runtime method returns 'Lilly'
    validation_test_2 = MethodValidation.generate_response_test(" == 'Lilly'",[])
    assert(validation_test_2.kind_of?(RuntimeMethod))
    assert_equal(
      true,
      MethodValidation.new.use_runtime_method_2(validation_test_2,test_2_method)
    )
    validation_test_3 = MethodValidation.generate_response_test(" != 'Lilly'",[])
    assert_equal(
      false,
      MethodValidation.new.use_runtime_method_2(validation_test_3,test_2_method)
    )    
#    
#    # Test that a runtime method returns the value it is passed
#    test_3_param_1 = MethodParameter.new
#    test_3_method = RuntimeMethod.new(MethodUsage.new(test_3_param_1))
#    test_3_method.push(Statement.new(Return.new,test_3_param_1))
#    test_3_validation = MethodValidation.generate(
#      {:condition=>' == "Pip"',:target=>'response',:params=>['Pip'.to_literal],:runtime_method=>test_3_method})
#    assert_equal(
#      'Pip',
#      MethodValidation.new.use_runtime_method(
#        test_3_validation,ParametersContainer.new(test_3_method.to_declaration)        
#      )
#    )
    
    
  end
  
  
  def test_use_runtime_method      
    
    # Test that the following runtime method returns true
    # def method_0
    #   return true
    # end
    method_0 = RuntimeMethod.new(MethodUsage.new)
    method_0.push Statement.new(Return.new,True.new)
    assert_equal(true,MethodValidation.new.use_runtime_method(method_0))
    
    # Test that the following runtime method returns 'Kelly'
    # def method_1
    #   return 'Kelly'
    # end
    method_1 = RuntimeMethod.new(MethodUsage.new)
    method_1.push Statement.new(Return.new,'Kelly'.to_literal)
    assert_equal('Kelly',MethodValidation.new.use_runtime_method(method_1))
    assert_not_equal('kelly',MethodValidation.new.use_runtime_method(method_1))    
    
    # Test that this method returns the string passed to it
    # def method_2(param_1)
    #   return param_1
    # end
    method_2_param_1 = MethodParameter.new
    method_2 = RuntimeMethod.new(MethodUsage.new(method_2_param_1))
    method_2.push Statement.new(Return.new,method_2_param_1)
    assert_equal('Marc',MethodValidation.new.use_runtime_method(method_2,ParametersContainer.new('Marc'.to_literal)))
    
    # Test that this method adds both of the numbers and returns it
    method_3_param_1, method_3_param_2 = MethodParameter.new, MethodParameter.new
    method_3 = RuntimeMethod.new(MethodUsage.new(method_3_param_1,method_3_param_2))
    method_3_unknown_1 = Unknown.new
    method_3.push Statement.new(method_3_unknown_1,Equal.new,method_3_param_1,Addition.new,method_3_param_2)
    assert_equal(8,MethodValidation.new.use_runtime_method(method_3,ParametersContainer.new(2.to_literal,6.to_literal)))
    assert_not_equal(9,MethodValidation.new.use_runtime_method(method_3,ParametersContainer.new(2.to_literal,6.to_literal)))    
    
  end  
      
end