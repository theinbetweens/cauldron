$LOAD_PATH << File.expand_path('../../../../../lib',__FILE__)

require 'required'
require 'test/unit'

class TestStatement < Test::Unit::TestCase
  
  def setup
    
    # Create a simple literal declaration statement
    @var_a = Unknown.new
    @simple_statement = Statement.new(@var_a,Equal.new,Literal.new('Daggerfall'))
    
    # Create a statement with a variable in it
    @var_b = 'Arena'.to_var
    @var_c = Unknown.new
    @statement_b = Statement.new(@var_c,Equal.new,InstanceCallContainer.new(@var_b,Chop.new))
    
    # Create a return statement
    @return_statement_a = Statement.new(Return.new,@var_b)
    
    # Create a statement with mulitiple variables
    @var_e = 3.to_var
    @var_f = 6.to_var
    @var_g = Unknown.new
    @statement_c = Statement.new(@var_g,Equal.new,@var_e,Addition.new,@var_f)
    
    # Create some statements that's unknown variable is determined
    @wally = StringVariable.new('Wally')
    @chopped_wally = Unknown.new
    @chop_wally = Statement.new(@chopped_wally,Equal.new,InstanceCallContainer.new(@wally,Chop.new))
    @number_9 = FixnumVariable.new(9)
    @declared_number = Unknown.new
    @statement_d = Statement.new(@declared_number,Equal.new,@number_9)
    
    # Create some statements that's unknown variable can't be determined
    @var_h = Unknown.new
    @var_i = Unknown.new
    @statemnet_e = Statement.new(@var_h,Equal.new,@chopped_wally)
    @statemnet_f = Statement.new(@var_i,Equal.new,InstanceCallContainer.new(@chopped_wally,Chop.new))    
    
    # Create a statement that accesses an array variable
    animals = ['bear','badger','bison','beever','bird'].to_var
    
    # 3.times
    @three_times = Statement.new(InstanceCallContainer.new(3.to_literal,Times.new))
    
    # Return 'sparky' method
    #    def return_sparky
    #      return 'sparky'
    #    end
    @return_sparky_method = RuntimeMethod.new(MethodUsage.new)
    return_sparky = Statement.new(Return.new,'sparky'.to_literal)
    @return_sparky_method.push(return_sparky)
    
  end
  
  def teardown
    System.reset
  end  
  
  def test_simple_valid_syntax
    
    # Statement: var0 = var1.chop
    declaration_statement = DeclarationStatement.new(Unknown.new,Equal.new,InstanceCallContainer.new(Unknown.new,Chop.new))
    assert_equal(false,declaration_statement.valid_syntax?)
    
    # Statement: var0 = 'test'.chop
    chop_string_statement = DeclarationStatement.new(Unknown.new,Equal.new,InstanceCallContainer.new(Literal.new('test'),Chop.new))
    assert_equal(true,chop_string_statement.valid_syntax?)
    
    # Statement: return false
    return_statement = Statement.new(Return.new,False.new)
    assert_equal(true,return_statement.valid_syntax?)
    
  end
  
  def test_not_declared_variables
    
    # Create a simple declaration statement var1 = var0
    simple_declaration_statement = DeclarationStatement.new(Unknown.new,Equal.new,Unknown.new) 
    assert_equal(false,simple_declaration_statement.valid_syntax?)
    
    # Check the number of unknown variables returned
    assert_equal(1,simple_declaration_statement.not_declared_variables.length)
    
    # Create the statement with undeclared variables in an instance call
    declaration_statement = DeclarationStatement.new(Unknown.new,Equal.new,InstanceCallContainer.new(Unknown.new,Chop.new))
    assert_equal(false,declaration_statement.valid_syntax?)
    
    # Check the number of undeclared variables
    assert_equal(1,declaration_statement.not_declared_variables.length)
    
    # Create a declared variable that references itself var0 = var0 (this is valid ruby, var0 is just nil)
    unknown_var = Unknown.new()
    referencing_statement = DeclarationStatement.new(unknown_var,Equal.new,unknown_var)
    assert_equal(0,referencing_statement.not_declared_variables.length)
    
    # Check that undeclared variable is found in array access
    # e.g var_c = var_b[var_a]
    # 1.  
    var_1_a = 0.to_var
    var_1_b = ['dogs','cats','mass hysteria'].to_var
    var_1_c = Unknown.new
    statement_1 = Statement.new(var_1_c,Equal.new,ArrayAccess.new(var_1_b,var_1_a))
    assert_equal(2,statement_1.not_declared_variables.length)
    
    # Check that push statements are properly handled
    vault_101 = Unknown.new() # e.g ArrayVariable
    butch = Unknown.new # e.g. StringVariable
    example_1 = Statement.new(InstanceCallContainer.new(vault_101,Push.new,butch))
    assert_equal(2,example_1.not_declared_variables.length)
    
    # 2.  
    # Check that arguments are picked up as "not_declared_variables"
    # e.g. var_b = RuntimeMethod.new(var_a) -> should return "var_a"
    var_a = Unknown.new
    var_b = Unknown.new
    var_b_statement = Statement.new(var_b,Equal.new,ClassMethodCallContainer.new(RuntimeMethodClass.new,New.new,var_a))
    assert_equal(1,var_b_statement.not_declared_variables.length)
    
    # Create a declared variable that references itself var0 += var0      
    # TODO  Currently only uses equal    
      
  end
  
  # Check that I am able to substitute one variable for another 
  # within a statement.
  #
  def test_variable_subst
   
    # Create the substitute variable (the one to replace the current one) self.class = String
    subst_variable = MethodParameter.new

    # Create the variable to be replaced self.class = String
    replacable_variable = Unknown.new
    
    # Create the statement 'tests' = var.chop
    tests = 'test'.to_var
    # TODO  This contains duplicate statements - when you describe it self.class = String twice
    # e.g 'tests' = var.chop
    statement = Statement.new(tests,Equal.new,InstanceCallContainer.new(replacable_variable,Chop.new))
    
    # Confirm that the statement isn't valid sytax becuase replacable_variable has no actual value
    assert_equal(false,statement.valid_syntax?)
    
    # Replaced the replacable variable e.g. var1 in var0 = var1.chop
    assert_nothing_raised(){ statement.subst(replacable_variable.variable_id,subst_variable) }
    
    # Check the printed statement
    assert_equal('var_'+tests.variable_id.to_s+' = var_'+replacable_variable.variable_id.to_s+'.chop',statement.write)
    
    # Check that a statement is returned
    assert_equal( true,statement.subst(subst_variable.variable_id,replacable_variable).kind_of?(Statement) )

    # Check the resulting statement is properly updated
    updated_statement = statement.subst(replacable_variable.variable_id,subst_variable)
    
    # Check the original statement is printed out in the same way - after the substiution
    assert_equal('var_'+tests.variable_id.to_s+' = var_'+replacable_variable.variable_id.to_s+'.chop',statement.write)        
    
    # Check the print out for the updated statement
    assert_equal('var_'+tests.variable_id.to_s+' = var_'+subst_variable.variable_id.to_s+'.chop',updated_statement.write)
    
    # Check that the variable_ids of both statements don't match
    assert_not_equal(statement[2].subject.variable_id,updated_statement[2].subject.variable_id)    
    
  end
  
  def test_find_variable
    
    # Test a variable with the correct id is returned
    assert(@simple_statement.find_variable(@var_a.variable_id).kind_of?(Variable))
    assert_equal(@var_a.variable_id,@simple_statement.find_variable(@var_a.variable_id).variable_id)    
    
    # Attempt to retrieve a variable that doesn't exist
    assert_raise(FailedToFindVariableError){@simple_statement.find_variable(Variable.variable_id+1)}    
    
    # Attempt to find a variable used in the statement i.e. not declared in the statement
    assert_nothing_raised(){@statement_b.find_variable(@var_b.variable_id)}
    assert_equal(@var_b.variable_id,@statement_b.find_variable(@var_b.variable_id).variable_id)
    
    assert_kind_of(Variable,@statement_b.find_variable(@var_b.variable_id))
    assert_kind_of(Variable,@statement_b.find_variable(@var_c.variable_id))
    
    # Test that returned variable isn't the original instance
    assert_not_equal(@var_b.object_id, @statement_b.find_variable(@var_b.variable_id))
    
    # Test find_variable a return statement
    assert(@return_statement_a.find_variable(@var_b.variable_id).kind_of?(Variable))
    assert_equal(@var_b.variable_id,@return_statement_a.find_variable(@var_b.variable_id).variable_id)    

    # Test that an unknown variable is retrieved and still unknown
    assert_equal(true,@chop_wally.find_variable(@chopped_wally.variable_id).kind_of?(Unknown))    
    
    assert_equal(true,@statemnet_e.find_variable(@var_h.variable_id).kind_of?(Unknown))
    assert_equal(true,@statemnet_f.find_variable(@var_i.variable_id).kind_of?(Unknown))    
    
  end
  
  # Check that the statement is properly copied.
  #
  def test_copy
    
    # Check that the variable_ids are different
    assert_not_equal(@statement_b.object_id,@statement_b.copy.object_id)
    
    # Check each of the variables within the statements
    assert_equal(@statement_b.length,@statement_b.copy.length)
    copied_statement = @statement_b.copy
    @statement_b.each_with_index do |statement,i|
      assert_not_equal(statement.object_id,copied_statement[i].object_id)
    end
    
    # Check that the statement_type is maintained for copied statements.
    statement_1 = Statement.new(@var_a,Equal.new,Literal.new('Daggerfall')) 
    #statement_1.statement_type = StatementStructure::DECLARATION_STATEMENT
    assert_equal(statement_1.copy.statement_type,statement_1.statement_type)
    
  end
  
  # Tests it can identifiy the structure of the statement.
  #
  def test_statement_type
    assert_equal(StatementStructure::DECLARATION_STATEMENT,@statement_b.statement_type)  
    assert_equal(StatementStructure::RETURN_STATEMENT,@return_statement_a.statement_type)
    
    # Test some poorly structured statements
    assert_raises(UnknownStatementType){Statement.new(RequirementsVariable.new,RequirementsVariable.new).statement_type}
  end
  
  # Presumes the statement is a declaration statement and returns the
  # specified variable in context.
  #
  def test_find_variable_in_declaration_statement
    
    # Attempt to retrieve both variables used in the statement (var_c = var_b.chop)
    assert(@statement_b.send(:find_variable_in_declaration_statement,@var_c).kind_of?(Variable))
    assert(@statement_b.send(:find_variable_in_declaration_statement,@var_b).kind_of?(Variable))    
    
    # Attempt to retrieve variable not used in statement
    assert(@statement_b.send(:find_variable_in_declaration_statement,@var_b).kind_of?(Variable))        
    
    # Attempt to retrieve variable for statement with three variables
    assert(@statement_c.send(:find_variable_in_declaration_statement,@var_e).kind_of?(Variable))                
    assert(@statement_c.send(:find_variable_in_declaration_statement,@var_f).kind_of?(Variable))                
    assert(@statement_c.send(:find_variable_in_declaration_statement,@var_g).kind_of?(Variable))            
    
  end
  
  def test_required_variable_ids
    
    # Confirm that the simple statement var = 'daggerfall' has no dependencies
    assert_equal(0,@simple_statement.required_variable_ids.length)
    
    # Confirm varA = varB.chop has one dependency
    assert_equal(1,@statement_b.required_variable_ids.length)
    assert_equal(@var_b.variable_id,@statement_b.required_variable_ids.first)    
    
    assert_equal(2,Parser.run('var3 = var1 + var2').required_variable_ids.length)
    
  end
  
  def test_to_literal_string
    assert_equal("var='Daggerfall'",@simple_statement.to_literal_string)
  end
  
  # Tests that unrealised variables can be identified in a statement
  #
  def test_unrealised_variables
    
    # 1.  var = 'test'
    example_1 = Statement.new(Unknown.new,Equal.new,'test'.to_literal)
    assert_equal(1,example_1.unrealised_variables.length)
    
    # 2.  Test NilVariables aren't regared as unrealised
    example_2 = Statement.new(Unknown.new,Equal.new,NilVariable.new)
    assert_equal(1,example_2.unrealised_variables.length)
    
    # 3.  Check that a undeclared String Variable is caught
    example_3 = Statement.new(Unknown.new,Equal.new,StringVariable.new(nil))
    assert_equal(2,example_3.unrealised_variables.length)
    
    # 4.  Check that statements can contain no unreleasid variables
    manny = StringVariable.new('Manny')
    example_4 = Statement.new(FixnumVariable.new(5),Equal.new,InstanceCallContainer.new(manny,StringLength.new))
    assert_equal(0,example_4.unrealised_variables.length)
    
    # 5.  Check the instance calls are caught
    nil_string_variable = StringVariable.new(nil)
    unknown_example_5 = Unknown.new
    example_5 = Statement.new(unknown_example_5,Equal.new,InstanceCallContainer.new(nil_string_variable,StringLength.new))
    assert_equal(2,example_5.unrealised_variables.length)
    assert(example_5.unrealised_variables.any? {|x| x.variable_id == nil_string_variable.variable_id})
    assert(example_5.unrealised_variables.any? {|x| x.variable_id == unknown_example_5.variable_id})
    
    # 6.  Check that .push methods are properly caught
    #     e.g. var_34.push(var_24)
    vault_101 = Unknown.new() # e.g ArrayVariable
    butch = Unknown.new # e.g. StringVariable
    example_6 = Statement.new(InstanceCallContainer.new(vault_101,Push.new,butch))
    assert_equal(2,example_6.unrealised_variables.length)
      
  end
  
  def test_variables
    
    # 1.  Check that the write number of variables are returned
    #     e.g. var_xx.push(var_xx)
    vault_101 = Unknown.new() # e.g ArrayVariable
    butch = Unknown.new # e.g. StringVariable
    example_1 = Statement.new(InstanceCallContainer.new(vault_101,Push.new,butch))
    assert_equal(2,example_1.variables.length)    
    
    # 2.  Check that literals are ignored
    assert_equal(0,@three_times.variables.length)
    
    # 3.  Check that accessed arrays are caught
    #     var_xx = var_a[0]
    countries = Statement.new(Unknown.new,Equal.new,ArrayAccess.new(['U.K','France','Poland'].to_var,0))
    assert_equal(2,countries.variables.length)
    
    # 4.  Check array access using a variable
    pip = 'pip'.to_var
    wooter = 'wooter'.to_var
    people = [pip,wooter].to_var
    people_access = Statement.new(Unknown.new,Equal.new,ArrayAccess.new(people,1.to_var))
    assert_equal(3,people_access.variables.length)
    assert(people_access.variables.any? {|x| x.variable_id == people.variable_id})
    
  end
  
  def test_write
    
  end
 
  def test_to_declaration
    
    # Check that statement returns a declaration statement
    assert_equal(true,@simple_statement.to_declaration.kind_of?(VariableDeclaration))
    
    # Check to_declaration command when excluding a variable
    assert_equal(
      "Statement.new(var_#{@var_c.variable_id}, Equal.new(), InstanceCallContainer.new(StringVariable.new('Arena'), Chop.new()))",
      @statement_b.to_declaration([@var_c.variable_id]).write
    )
    
  end
  
  def test_find_all_required_runtime_methods
    
    # Check that any empty array is returned if there are no runtime methods used
    assert_equal(0,@simple_statement.find_all_required_runtime_methods.length)        
    
    # 1.  Create a statement that calls a runtime method
    static_statement = Statement.new
    #static_statement.statement_type = StatementStructure::MISC_STATEMENT
    return_statement_method = RuntimeMethod.new(MethodUsage.new(),static_statement.to_var)
    return_statement = Statement.new(Return.new,'sparky')
    #return_statement.statement_type = StatementStructure::RETURN_STATEMENT
    return_declaration_statement = Statement.new(Return.new,return_statement.to_declaration )
    #return_declaration_statement.statement_type = StatementStructure::RETURN_STATEMENT
    return_statement_method.push(return_declaration_statement)    
    
    # 1a.   Create the statement that contains the method call
    statement_with_method_call = Statement.new(Unknown.new,Equal.new,DefCall.new(static_statement.to_var,return_statement_method))
    #statement_with_method_call.statement_type = StatementStructure::DECLARATION_STATEMENT
    assert_equal(1,statement_with_method_call.find_all_required_runtime_methods.length)
    assert(statement_with_method_call.find_all_required_runtime_methods.kind_of?(Array))    
        
  end
  
  def test_realise2
            
    # 1.  Test that a statement can realise itself with a pasted in history instance      
    #   a.  First create the context of the statement so the history instance can be created
    runtime_method_1 = RuntimeMethod.new(MethodUsage.new)
    unknown_variable_1 = Unknown.new
    statement_1 = Statement.new(unknown_variable_1,Equal.new,'sparky'.to_literal)        
    #statement_1.statement_type = StatementStructure::DECLARATION_STATEMENT
    runtime_method_1.push(statement_1)
    
    #   b.  Now get the history instance for the runime method with the statement
    runtime_method_1_history = runtime_method_1.history(ParametersContainer.new)
    
    #   c.  Check that the statement can be realised with the history instance
    realised_statement = statement_1.realise2(runtime_method_1_history)
    assert_equal(StringVariable,realised_statement.find_variable(unknown_variable_1.variable_id).class)
    assert_equal('sparky',realised_statement.find_variable(unknown_variable_1.variable_id).value)
    
    # 2.  Test that a statement that calls a method can be realised
    #   a.  Create the method that is called 
    return_sparky = Statement.new(Return.new,'sparky'.to_declaration)
    #return_sparky.statement_type = StatementStructure::DECLARATION_STATEMENT
    calling_runtime_method_2 = RuntimeMethod.new(MethodUsage.new,'sparky'.to_var,return_sparky)
    
    #   b.  Create the method that calls "calling_runtime_method_2"
    runtime_method_2 = RuntimeMethod.new(MethodUsage.new)
    unknown_variable_2 = Unknown.new
    statement_2 = Statement.new(unknown_variable_2,Equal.new,DefCall.new('sparky'.to_var,calling_runtime_method_2))
    #statement_2.statement_type = StatementStructure::DECLARATION_STATEMENT
    runtime_method_2.push(statement_2)
    
    #   c.  Retrieve the history instance for the runtime method
    history_2 = runtime_method_2.history(ParametersContainer.new,[calling_runtime_method_2])
    
    assert_equal(true,statement_2.realise2(history_2).find_variable(unknown_variable_2.variable_id).kind_of?(StringVariable))
    assert_equal('sparky',statement_2.realise2(history_2).find_variable(unknown_variable_2.variable_id).value)

    # 3.  Try complex return type e.g StatementVaraible
    #   a.  Create the method that is called
    #       def called_method
    #         return Statement.new(Return.new,'sparky')
    #       end
    #
    blank_statement = Statement.new
    #blank_statement.statement_type = StatementStructure::MISC_STATEMENT
    called_runtime_method_3 = RuntimeMethod.new(MethodUsage.new,blank_statement.to_var)
    
    #   b.  Create the statement that is returned as a variable. 
    returned_statement_variable = Statement.new(Return.new,'sparky')
    declared_return_statement_var = Unknown.new
    #declare_return_statement = Statement.new(declared_return_statement_var,Equal.new,returned_statement_variable.to_declaration)
    return_return_statement = Statement.new(Return.new,returned_statement_variable.to_declaration)    
    #return_return_statement.statement_type = StatementStructure::RETURN_STATEMENT
    #declare_return_statement = StatementStructure::DECLARATION_STATEMENT
    called_runtime_method_3.push(return_return_statement)
    
    #   c.  Create the method that includes a call to "called_runtime_method_3"
    runtime_method_3 = RuntimeMethod.new(MethodUsage.new) 
    unknown_variable_3 = Unknown.new
    statement_3 = Statement.new(unknown_variable_3,Equal.new,DefCall.new(blank_statement.to_var,called_runtime_method_3))
    #statement_3.statement_type = StatementStructure::DECLARATION_STATEMENT
    runtime_method_3.push(statement_3)

    #   d.  Retrieve the history object for "runtime_method_3"
    history_3 = runtime_method_3.history(ParametersContainer.new,[called_runtime_method_3])    
    assert_equal(true, statement_3.realise2(history_3).find_variable(unknown_variable_3.variable_id).kind_of?(StatementVariable) )
    
  end
  
  def test_classes_match?
    
    # Test a simple return statement for both negative and positive results
    return_statement = Statement.new(Return.new,6.to_literal)
    assert(return_statement.classes_match?(Return,Literal))
    assert_equal(false,return_statement.classes_match?(Return,Unknown))
    assert_equal(false,return_statement.classes_match?(Return,Literal,Unknown))    
    
  end
  
  def test_statement_type
    
    # Test that statement type is saved correctly - even after copying
    return_statement = Statement.new(Return.new,6.to_literal)
    #return_statement.statement_type = StatementStructure::RETURN_STATEMENT
    assert_equal(return_statement.statement_type,StatementStructure::RETURN_STATEMENT)
    assert_equal(return_statement.copy.statement_type,StatementStructure::RETURN_STATEMENT)
    
    # Test that return statements can be dynamically identified
    return_statement_without_statement_type = Statement.new(Return.new,8.to_literal)
    assert_nothing_raised(){return_statement_without_statement_type.statement_type}
    assert_equal(return_statement_without_statement_type.statement_type,StatementStructure::RETURN_STATEMENT)
    
  end
  
  def test_replace_variable_if
    
    # Create a simple statement will have it's variable replaced
    # unknown = 7
    statement_a_unknown = Unknown.new
    statement_a = Statement.new(statement_a_unknown,Equal.new,7.to_literal)      
    assert(statement_a.first.kind_of?(Unknown))
    modified_statement_a = statement_a.replace_variable_if(FixnumVariable.new(7)) {|x| x.uniq_id == statement_a_unknown.uniq_id }
    assert(modified_statement_a.first.kind_of?(FixnumVariable))
    
    # Create a statement with an instance call container 
    # unknown = 'test'.chop
    statement_b_unknown = Unknown.new
    statement_b = Statement.new(Unknown.new,Equal.new,InstanceCallContainer.new(statement_b_unknown,Chop.new))    
    modified_statement_b = statement_b.replace_variable_if('test'.to_var) do |x|
      x.uniq_id  == statement_b_unknown.uniq_id
    end
    assert(modified_statement_b.kind_of?(Statement))
    assert_equal(3,modified_statement_b.length)    
    assert_not_equal(modified_statement_b[2].subject.variable_id,statement_b_unknown.variable_id)
    
    # Create a statement with parameters in the statement
    # ['goo'].push('jon')
    statement_c_unknown = Unknown.new
    statement_c = Statement.new(InstanceCallContainer.new(['goo'].to_var,Push.new,statement_c_unknown))
    modified_statement_c = statement_c.replace_variable_if('jon'.to_var) do |x|
      x.uniq_id == statement_c_unknown.uniq_id
    end
    assert(modified_statement_c.kind_of?(Statement))  
    assert_not_equal(modified_statement_c[0][0].uniq_id,statement_c_unknown.uniq_id)

    # Create a statement with no matches
    # unknown = 5 + 6
    statement_d = Statement.new(Unknown.new,Equal.new,5.to_var,Addition.new,6.to_var)
    modified_statement_d = statement_d.replace_variable_if('jon'.to_var) do |x|
      x.uniq_id == 21312
    end    
    assert_equal(statement_d.write,modified_statement_d.write)
    
    # Create an instance call statement with no matches
    # unknown = var_a.length
    statement_e = Statement.new(Unknown.new,Equal.new,InstanceCallContainer.new('richardson'.to_var,StringLength.new))
    modified_statement_e = statement_e.replace_variable_if('jon'.to_var) do |x|
      if x.uniq_id == 3242
        next true
      end
      false
    end
    assert_equal(statement_e.write,modified_statement_e.write)
      
  end
  
  def test_to_var
    
    # Create a simple statement and check that it can be changed to a statement variable
    assert_equal(StatementVariable,@simple_statement.to_var.class)
    
    # Check that the content of the statement is pre-served
    assert_equal(@simple_statement.write,@simple_statement.to_var.value.write)
    assert_equal(@chop_wally.write,@chop_wally.to_var.value.write)    
    
    # Check that variable ids are maintained and classes are maintained
    chop_wally_var = @chop_wally.to_var
    @chop_wally.each_variable do |x|
      assert_equal(x.variable_id,chop_wally_var.value.find_variable(x.variable_id).variable_id)
      assert_equal(x.class,chop_wally_var.value.find_variable(x.variable_id).class)
    end
    
    # Check that the id of the generated statement variable can be set.
    set_variable_id = 0
    variable_with_set_id = @simple_statement.to_var(set_variable_id)
    assert_equal(0,variable_with_set_id.variable_id)
    
    # Change the id's are retained when using blocks
    assert_equal(89,@simple_statement.to_var(89,101).variable_id)
    # TODO  I should check that ids are retained inside the value of the statement variable
    #raise StandardError.new('jsadksadfjksd')
    runtime_method_a = RuntimeMethod.new(MethodUsage.new)
    runtime_method_a << @simple_statement
    realised_runtime_method_a = runtime_method_a.realise2([])
    assert_equal(@simple_statement.first.variable_id,realised_runtime_method_a.first.first.variable_id)
    assert_equal(@simple_statement.first.uniq_id,realised_runtime_method_a.first.first.uniq_id)    
    
  end
  
  def test_find_actual_variable
    
    # 1.  Check that the actual variable is returned from a statement
    assert_equal(@simple_statement[0].variable_id,@simple_statement.find_actual_variable(@simple_statement[0].variable_id).variable_id)
    assert_equal(@simple_statement[0].object_id,@simple_statement.find_actual_variable(@simple_statement[0].variable_id).object_id)
    
  end
  
  def test_select_all
    
    # Check that both Unknown's are found within the statement          
    statement = Statement.new(Unknown.new,Equal.new,InstanceCallContainer.new(Unknown.new,Chop.new))
    assert_equal(2,statement.select_all {|x| x.kind_of?(Unknown)}.length)
    
  end
  
  def test_equivalent?
    
    # Check that 'unknown = method_call' and 'unknown = "Sparky"' aren't equivalent
    unknown_method_call = Statement.new(
      Unknown.new,Equal.new,DefCall.new(StringVariable.new('Sparky'),@return_sparky_method)
    )
    #unknown_method_call.statement_type = StatementStructure::DECLARATION_STATEMENT
    unknown_sparky_declaration = Statement.new(
      Unknown.new,Equal.new,'Sparky'.to_literal
    )
    #unknown_sparky_declaration.statement_type = StatementStructure::DECLARATION_STATEMENT
    assert_equal(false,unknown_method_call.equivalent?(unknown_sparky_declaration))
    assert_equal(false,unknown_sparky_declaration.equivalent?(unknown_method_call))    
    assert(true,unknown_sparky_declaration.equivalent?(unknown_sparky_declaration))    
    
    # Check that two 'unknown = MethodUsage.new' are  caught as equivalent
    statement_1 = Statement.new(Unknown.new,Equal.new,ClassMethodCallContainer.new(MethodUsageClass.new,New.new))
    statement_2 = Statement.new(Unknown.new,Equal.new,ClassMethodCallContainer.new(MethodUsageClass.new,New.new))
    assert_equal(true,statement_1.equivalent?(statement_2))
    
  end
  
  def test_exchange_variables
    
    # Create a statement that includes a method variable and is replaced by a different variable
    method_variable_1 = MethodParameter.new
    unknown_variable_1 = Unknown.new
    statement_1 = Statement.new(unknown_variable_1,Equal.new,InstanceCallContainer.new(method_variable_1,Chop.new))      
    pip = 'pip'.to_var
    conversions = Hash.new()
    conversions[method_variable_1.variable_id.to_s.to_sym] = pip.copy
    assert(statement_1.exchange_variables(conversions).kind_of?(Statement))    
    assert_nothing_raised(){statement_1.exchange_variables(conversions).to_literal_string}
    assert_equal(
      'var_'+unknown_variable_1.variable_id.to_s+' = var_'+pip.variable_id.to_s+'.chop',
      statement_1.exchange_variables(conversions).write
    )
    
    # Create a statement that modifies an existing variable.
    
    
    # TODO  Test with the same variable used twice in a statement e.g. var_a = var_b+var_b
      
  end
  
  def test_creates_variable?
    
    # Check that a declaration statement creates a variable
    statement_1 = Statement.new(Unknown.new,Equal.new,6.to_declaration)
    assert(statement_1.creates_variable?)
    
    # Check that a statement doesn't create a variable
    statement_2 = Statement.new(Return.new,7.to_declaration)
    assert_equal(false,statement_2.creates_variable?)
    
    # Check that a statement that modifies a variable is detected
    statement_3 = Statement.new(InstanceCallContainer.new([].to_var,Push.new,'antz'.to_literal))
    assert_equal(true,statement_3.creates_variable?)
    
  end
  
  def test_created_variable
    
    # Test that declaration statements are handles 'var_a = 'bramble jelly'
    statement_1_unknown = Unknown.new
    statement_1 = Statement.new(statement_1_unknown,Equal.new,'bramble jelly'.to_literal)
    assert(statement_1.created_variable.kind_of?(Variable))
    assert_equal(statement_1_unknown.variable_id,statement_1.created_variable.variable_id)
    assert_not_nil(statement_1.created_variable_id)
    assert_not_nil(statement_1.created_variable.uniq_id)    
    assert_equal(statement_1.created_variable.uniq_id,statement_1_unknown.uniq_id)
    assert_equal(statement_1.created_variable.variable_id,statement_1.declared_variable.variable_id)
    
    # Test that statements the don't create a variable are appropriatly handled
    statement_2 = Statement.new(Return.new,'rowiage'.to_var)
    assert_equal(false,statement_2.creates_variable?)
    assert_raises(ImproperStatementUsageError){statement_2.created_variable}
    
    # Test that modifying statements have a new created variable
    statement_3_empty_array_var = [].to_var
    statement_3_empty_array_var.copy
    statement_3 = Statement.new(InstanceCallContainer.new(statement_3_empty_array_var,Push.new,'Normandy SR2'.to_literal))    
    assert(true,statement_3.creates_variable?)
    assert_nothing_raised(){statement_3.created_variable}
    assert(statement_3.created_variable.kind_of?(ArrayVariable))
    assert_equal(statement_3.created_variable.variable_id,statement_3_empty_array_var.variable_id)
#    assert_not_equal(
#      statement_3.created_variable.uniq_id,
#      statement_3_empty_array_var.uniq_id
#    )    
    
  end
  
  def test_tokens
    # TODO  This should be a Statement
    assert_equal(
      2,
      Statement.new(Unknown.new,Equal.new,Unknown.new).tokens.length
    )
  end
  
  def test_write_structure_simple
    assert_equal("a = b",Parser.run("var1 = var2").write_structure)
    assert_equal("a = b + c",Parser.run("var1 = var2 + var3").write_structure)
    assert_equal("a = b + c",Parser.run("var1 = var2 + 7").write_structure)
    assert_equal("a = b + c",Parser.run("var1 = var2 + 'adeley'").write_structure)
    assert_equal("a.chop",Statement.new(Parser.run("var1.chop")).write_structure)
    assert_equal("a = b.chop + c",Parser.run("var2 = var5.chop + 9").write_structure)
    assert_equal("a = b.chop + a",Parser.run("var2 = var5.chop + var2").write_structure)
  end
  

end