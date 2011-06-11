# The method generator is passed a number of runtime method instances that it uses
# to test the runtime methods it generates.  Those that pass the tests are approved
# those that don't are rejected.  
#
# Creating these runtime method instance is a bit verbose so I've created this 
# class to generate them based on the condition passed through.  
#
class MethodValidation
   include MethodTester
  
  # Returns a runtime method instance that expects to be passed 
  # a runtime method instance and evaluate an attribute of the 
  # instance. 
  #
  # For example it might be passed the condition=> ".kind_of?(RuntimeMethod)" 
  # and would generate a runtime method instance that would be written like
  # the following.
  #
  # def method_0(var)
  #   return true if var.kind_of?(RuntimeMethod)
  #   return false
  # end
  # 
  def self.generate_attribute_test(condition)
    method_var = MethodParameter.new
    test_method = RuntimeMethod.new(MethodUsage.new(method_var))  
    test_method.push(HackStatement.new(
      'return true if '+method_var.write+condition
    ))
    test_method.push(Statement.new(Return.new,False.new))      
    return test_method
  end
  
  # Returns a runtime method instance that expects a runtime 
  # method instance as a parameter.  It will then use the passed
  # in runtime method instance as runtime code and evaluate the
  # response from the using the method.
  #
  # So if it was passed the condition=>' == "Dad"' and the params
  # => ['Dad'] it would generate a runtime method instance that 
  # would write() like the following.
  # 
  #  def method_8(var_0)
  #    var_1 = RuntimeMethod.new(MethodUsage.new) 
  #    var_1.push(Statement.new(Return.new,DefCall.new(nil,var_0,*<params>))) 
  #    var_2 = RuntimeClass.new('TempClassName',var_0,var_1) 
  #    return true if ClassEvaluation.new.evaluate_class(var_2,var_1.method_name)  <condition>
  #    return false 
  #  end
  #
  def self.generate_response_test(condition,params)
    method_var = MethodParameter.new
    test_method = RuntimeMethod.new(MethodUsage.new(method_var))  
    
    # Create the enterance runtime method
    # 1.  var_1 = RuntimeMethod.new(MethodUsage.new)
    var_1 = Unknown.new
    test_method.push(
      Statement.new(
        var_1,
        Equal.new,
        ClassMethodCallContainer.new(
          RuntimeMethodClass.new,
          New.new,
          ClassMethodCallContainer.new(MethodUsageClass.new,New.new)
        )
      )
    )
    # 2.   var_1.push(Statement.new(Return.new,DefCall.new(nil,var_0,*<params>))) 
    test_method.push(
      Statement.new(
        InstanceCallContainer.new(
          var_1,
          Push.new,
          ClassMethodCallContainer.new(
            StatementClass.new,
            New.new,
            ClassMethodCallContainer.new(
              ReturnClass.new,
              New.new
            ),
            ClassMethodCallContainer.new(
              DefCallClass.new,
              New.new,
              Nil.new,
              method_var,
              *params
            )
          )
        )
      )
    )
    # 3.  var_2 = RuntimeClass.new('TempClassName',var_0,var_1) 
    var_2 = Unknown.new
    test_method.push(
      Statement.new(
        var_2,
        Equal.new,
        ClassMethodCallContainer.new(
          RuntimeClassClass.new,
          New.new,
          'TempClassName'.to_literal,
          method_var,
          var_1
        )
      )
    )
    # 4.  var_3 = ClassEvaluation.new
    var_3 = Unknown.new
    test_method.push(
      Statement.new(
        var_3,
        Equal.new,
        ClassMethodCallContainer.new(
          ClassEvaluationClass.new,
          New.new        
        )
      )
    )
    # 5.  return true if var_3.evaluate_class(var_2,var_1.method_name)<condition>
    s = Statement.new(
      If.new,
      Container.new(
        InstanceCallContainer.new(
          var_3,
          EvaluateClassCall.new,
          var_2,
          InstanceCallContainer.new(var_1,MethodNameCall.new)
        ),
        Raw.new(condition)      
      )
    )
    os = OpenStatement.new(s)
    os << Statement.new(Return.new,True.new)
    test_method.push(os)
    
    #test_method.push(s)
    
    # 6.  return false  
    test_method.push(
      Statement.new(
        Return.new,
        False.new
      )
    )
    return test_method
  end
  
end