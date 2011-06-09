require 'required'
require 'test/unit'

class TestRealisedRuntimeMethod < Test::Unit::TestCase
  
  def setup
    
    # Create the method usage 
    @method_var_a = MethodParameter.new(Requirement.new(InstanceCallContainer.new(This.new,ClassCall.new),Equivalent.new,StringClass.new))
    # Not used in the method
    @method_var_b = MethodParameter.new(Requirement.new(InstanceCallContainer.new(This.new,ClassCall.new),Equivalent.new,StringClass.new))
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
    
  end
  
  def teardown
    System.reset
  end  
  
  # 1.  Test last variables are returned
  # 2.  Test that nested variables are ignored
  # 3.  Test that overridden variables are updated.
  #
  def test_final_variables

      # Check that the right number of variables are returned for the method
      #  #
      #  # @param  [StringVariable] 'oblivion'
      #  # @param  [StringVariable] 'daggerfall'
      #  #
      #  def method_0(var_0, var_1)
      #    var_3 = 9 
      #    var_4 = var_0.chop 
      #    var_5 = var_4.length 
      #    var_6 = var_3  +  var_5 
      #    var_7 = var_4.length 
      #  end
      
      # Create the realised runtime method
      realised_simple_method = @simple_method.realise2(['oblivion','daggerfall'])
      
      assert_equal(
        7,
        realised_simple_method.final_variables().length
      )
      assert(realised_simple_method.final_variables().all? {|x| x.kind_of?(Variable)})
      
      # 2.  Check that variables declared in nested/open statements are ignored
      
      # `a. Create method with an open statement in it.  The final method
      #     will look like the following:
      #     
      #     def test_method
      #       var_0 = 'firefox'
      #       if var_0.length == 7
      #         var_1 = 'IE'
      #       end
      #     end
      statement_with_open_statement = RuntimeMethod.new(MethodUsage.new)
      # TODO  It would be useful to have a to_declaration_statement
      firefox = 'firefox'.to_declared_variable_statement
      statement_with_open_statement.push(firefox)
      firefox_var = firefox.declared_variable
      if_statement = Statement.new(IfContainer.new(InstanceCallContainer.new(firefox_var,StringLength.new),Equivalent.new,7.to_literal))
      open_if_statement = OpenStatement.new(if_statement)
      open_if_statement.push('IE'.to_declared_variable_statement)
      statement_with_open_statement.push(open_if_statement)
      realised_statement_with_open_statement = statement_with_open_statement.realise2(ParametersContainer.new)

      # b.  Check that only one variables is availabe
      assert_equal(1,realised_statement_with_open_statement.final_variables(ParametersContainer.new).length)
      
      # 3.  Check that overriden variables are updated so that the new value is used
      realised_build_xxx_method = @build_xxx_method.realise2(ParametersContainer.new)
      assert_equal(2,realised_build_xxx_method.final_variables(ParametersContainer.new).length)      
      assert_equal(true,realised_build_xxx_method.final_variables(ParametersContainer.new).any? {|x| x.variable_id == @blank_variable.variable_id} )            
      assert_equal(true,realised_build_xxx_method.final_variables(ParametersContainer.new).any? {|x| x.variable_id == @x_variable.variable_id} )                  
      assert_equal(false,realised_build_xxx_method.final_variables(ParametersContainer.new).any? {|x| x.variable_id == -10 })
      
      # 4.  Test with additional method calls
           
  end  
  
  def test_copy
  
    # Create a realised method from a simple runtime method
   runtime_method_a = RuntimeMethod.new(MethodUsage.new) 
   runtime_method_a.push(Statement.new(Unknown.new,Equal.new,8.to_literal))
   realised_method_a = runtime_method_a.realise2(ParametersContainer.new)
   assert_equal(realised_method_a.length,realised_method_a.copy.length)
    
  end
  
end