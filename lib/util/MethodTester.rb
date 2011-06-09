module MethodTester
  
  # Returns a runtime method instance that will call the supplied 
  # runtime method and then test the result against the test 
  # runtime method.
  #
  # @param  solution_method                 This is the method that should generate a runtime
  #                                         method instance that can be used and produce results
  #                                         that satisfy the requirements.
  # @param  return_value_evaluation_method  This method is used to evaluate the result return
  #                                         from using the solution method.
  #
  def access_method(solution_method,return_value_evaluation_method)
    
    # Construct the method to test the generated runtime method
    testing_method = RuntimeMethod.new(MethodUsage.new)
    generated_instance = Unknown.new
    
    # Create the call that captures what is returned by the test method
    testing_method << Statement.new(generated_instance,Equal.new,DefCall.new(nil,solution_method))
    
    # Return the result of the "is_runtime_method_test"
    testing_method << Statement.new(Return.new,DefCall.new(nil,return_value_evaluation_method,generated_instance))        
    
    return testing_method
    
  end  
  
  # Returns the results of calling the runtime method with the parameters 
  # provided.
  # 
  # @param  runtime_method    A runtime method instance with on or more parameters
  #
  def use_runtime_method(runtime_method,params=ParametersContainer.new)
#      MethodEvaluation.new.evaluate_method(
#                requirement_testing_method,
#                ParametersContainer.new,
#                [reqs,copied_method]+@runtime_methods
#              )      
    access_method = RuntimeMethod.new(MethodUsage.new)  
    access_method.push(Statement.new(Return.new,DefCall.new(nil,runtime_method,*params)))
    return MethodEvaluation.new.evaluate_method(
      access_method,
      ParametersContainer.new,
      [runtime_method]
    )
  end
  
  # Generates a class that contains the passed through method and then
  # calls the passed method using the params provided.
  #
  # So if the supplied runtime_method would when written looked like
  # 
  # def method_7
  #   return true
  # end
  #
  # It would then be put into the class and "method_7" would be called using 
  # the passed parameters.
  #
  # @param  runtime_method    A runtime method instance with zero of more parameters
  #
  # 
  def use_runtime_method_2(runtime_method,*params)
    runtime_class = RuntimeClass.new('RuntimeMethodTester',runtime_method)
    ClassEvaluation.new.evaluate_class_2(runtime_class,runtime_method.method_name,*params)
    # return ClassEvaluation.new.evaluate_class(runtime_method,runtime_method.method_name)  
    
  end
  
end