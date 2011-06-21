require "tsort"

# A code handler continualy considers how to extend the complexity 
# of a method in a custom class given the intial starting methods
# already availble within the class.  
#
# It also can refactor the code into separate methods thereby 
# reusing the same functionality.
# 
# Essentially it just tries to create as many uniquely new variables as it
# can.  Note they are consider unique if the process to create them is 
# new, NOT whether or not there value is new.
#
class CodeHandler
  
  attr_reader :runtime_methods
  attr_writer :default_structures
  
  @@CODE_HANDLER_ID = 0
  
  def initialize(runtime_methods=[],structures=nil)
    @runtime_methods = runtime_methods
    @entrance_method = create_entrance_method
    @code_handler_id = @@CODE_HANDLER_ID
    @@CODE_HANDLER_ID += 1
    
    # These are the default statement structures if non-are supplied
    @default_structures = [
      DeclareVariableAsVariableStructure.new,
      StatementStructure2.new(StatementStructure2.declared_runtime_method),
      StatementStructure2.new(StatementStructure2.declared_array),      
      StatementStructure2.new(StatementStructure2.declared_string_addition),            
      DeclareNewInstanceStructure.new(MethodUsageClass.new,RuntimeMethodClass.new)
     ]
     
      # If structures are supplied the overwrite the default structures
      @default_structures = structures unless structures.nil? 
  end
  
  # Returns a string that prints out how the dynamic code for the
  # code handler currently looks.
  #
  def write

    dynamic_code = "class #{class_name}"+"\n"
    
    # Include each of the avaialble runtime methods
    @runtime_methods.each do |x|
      dynamic_code += x.write(ParametersContainer.new,1)
    end
    
    # Now add the entrance method
    dynamic_code += @entrance_method.write(ParametersContainer.new,1)
    
    dynamic_code += "end"
    return dynamic_code
  end
  
  # Returns an array of method instances containing various numbers of statements.
  # 
  # 1.  At this point we are creating a statement to go straight into a method or 
  #     into a nested statement.  First we find all the available variables in the 
  #     context.  For this to work the variables should be saved with a scope.  At
  #     this point it isn't concerning it's self with the dependencies for the variable.
  #     It does however have to take into consideration scope.  As such every nested
  #     statement maintains an array of it's level e.g. [5,7] for a two level nested 
  #     statement.  This would mean that varibles with a scope level of 5 or 7 would
  #     be valid consideration.
  #     
  # 2.  Next using the variables available to it it constructs a number of different 
  #     statements.  
  #
  # 3.  From this statement it needs to work backwards to construct the full method.
  #     It does this by finding all the dependencies that have the same scope level.
  #     After that has been done, if finds and adds all the dependcies on the other 
  #     scope level.
  # 
  # 4.  With the method constructed the value for the new variable can be asscertained.
  #     The asscertained value gets added to available array.  Also if a variable is 
  #     overwritten within the nested statement then its value is included with a scope
  #     value outside the nested statement.  Specifically a scope level the same as the
  #     variable that was overridden.  The variable simple has a depencey on the nested
  #     statement.  This allows it to rebuild the statements in the correct order.  It 
  #     can then check the scopes and wrap the nested statement accordingly.
  #
  # @param  count                 The number of itterations to go through when generating new
  #                               runtime method arrangements.
  # @param  additional_available  Any additional values that should be made available when 
  #                               generating statements.
  #  
  def itterate(count=1,additional_available=[])

    # Create an array to contain the vessels currently available
    initial_copied_method = @entrance_method.copy
    initial_copied_method.clear              
    vessels = [initial_copied_method]
    
    # Create the array to contain the available variables and the initial runtime method calls
    available = []
    available += additional_available
    @runtime_methods.each {|x| available += x.callable_combinations}  
    
    # Set the scope id for all the method calls
    available.each {|x| x.scope_id = initial_copied_method.scope_id}
    
    # Maintains all the statements and their dependencies
    dependencies = StatementDependencies.new
    
    # Completed methods
    results = []
        
    # Itterate over the number of times specified
    count.times do |i|        

      # Keep track of the newly created variables
      newly_created_variable = []
      
      # Keeps track of newly created vessels
      newly_created_vessels = []
      
      # For each vessel create appropriate statements
      vessels.each do |vessel|
        
        # Find potential new statements available to the current vessel
        new_statement_results = find_possible_new_statements(vessel,available,dependencies)

        # Find the statement dependencies for each statement
        new_statement_results.each do |y|      
        
          # Create the vessel for the new statement
          new_vessel = vessel.copy                    

          # Create a runtime method with the statement and all the dependencies 
          copied_method = build_minimalist_method(@entrance_method,y,dependencies)

          # Realise the generated method
          begin
            realised_method = copied_method.realise2(ParametersContainer.new,@runtime_methods)
          rescue ImproperStatementUsageError => e
            
            # TODO  I have rejected statements "var = <#statement_variable>.declare_variable" if the statement
            # variable doesn't represent a declaration statement.  I don't know if this is the right way to
            # do things.  It might be better to return a NilVariable or prevent it from ever being created.
            
            # TODO  I should check this is logged
            StandardLogger.instance.warning('Method rejeceted')       
            StandardLogger.instance.warning(e)                   
            next
          end       
          
          results.push(realised_method)       
          
          # TODO  I should determine the nature of the statement and then 
          #       determine the new variables available.
          # - I should maybe save structures with statements.    
          
          raise StandardError.new('Statement type has not defined for this statement') if y.statement_type.nil?

          # Determine the id of the statement that declares the value
          #case(y.statement_type)
          #  when StatementStructure::DECLARATION_STATEMENT
          if((y.statement_type == StatementStructure::MODIFYING_STATEMENT)or(y.statement_type == StatementStructure::DECLARATION_STATEMENT))

              #declared_variable_id = y.created_variable.variable_id                       
              variable_uniq_id = y.created_variable.uniq_id                       

              # Find the value of the variable within the realised method and set it's scope
              #resulting_variable = realised_method.find_variable(declared_variable_id)   
              resulting_variable = realised_method.find_variable(variable_uniq_id)     

              if y.kind_of?(BlockStatement)
                resulting_variable.scope_id = y.scope_id
                resulting_variable.clear
              else
                resulting_variable.scope_id = vessel.scope_id
              end
              newly_created_variable.push(resulting_variable)          
          
              #new_vessel = realised_method.find_statement_that_declares_variable(declared_variable_id)
              # TODO  Check this works with uniq_id          
              new_vessel = realised_method.find_statement_that_created_variable(variable_uniq_id)
              
              # Find the statement from the typed method that declares the variable
              # NOTE  I wonder if it would be quicker and safe to add the realised statement here
              #declaring_statement = realised_method.find_statement_that_declares_variable(declared_variable_id)
              # TODO  Check this works with uniq_id
              declaring_statement = realised_method.find_statement_that_created_variable(variable_uniq_id)
              dependencies.push(declaring_statement)          
          
              # If the new statement was a nested statement then add as vessel
              if y.kind_of?(BlockStatement)
                new_vessels_scope = [new_vessel.scope_id]
                new_vessels_scope += vessel.scope
                new_vessel.scope = new_vessels_scope
                new_vessel.clear
                newly_created_vessels.push(new_vessel)
              end          
          
#          when StatementStructure::MODIFYING_STATEMENT:
    
#             # exit
#              # Need to save modified statement;
#              StandardLogger.instance.warning('I think I need to treat modifying statements as if they declare new variables')
#              
#              # TODO  I'm not certain this isn't going to add loads of statement
#              StandardLogger.instance.info('Statement ID: '+y.statement_id.to_s)              
#              StandardLogger.instance.info(': '+y.write)              
#              
#              # Adding the statement the newly modified statement
#              dependencies.push(realised_method.select {|stment| stment.statement_id == y.statement_id}.first)
#            elsif(StatementStructure::USAGE_STATEMENT)  
            else
              raise StandardError.new('Unknown statement_type "'+y.statement_type+'" "'+y.write+'"')
          end
          
        end
          
      end
      
      # Add the new variables to available list
      # TODO  newly_created_variable is an array - it should be newly_created_variables
      available += newly_created_variable                         
      
      # Add the new vessel to the list
      vessels += newly_created_vessels      
         
    end  
    return results
    
  end
  
  def self.reset_global_id
    #http://www.zenspider.com/Languages/Ruby/QuickRef.html
    unless $".include?('test/unit.rb')
      StandardLogger.log 'WARNING: Resetting variable id, this should only be done for tests'
    end
    @@CODE_HANDLER_ID = 0
  end    
  
  def class_name
    return "RuntimeCodeHandler"+@code_handler_id.to_s
  end
  
protected
  
  # Returns an array of new statements after removing any statements
  # that have previously been considered when generating code.
  #
  # TODO  This needs re-thought for seanarios when new containers become
  #       available.
  #
  # @param  possible_statements       
  # @param  considered_statements     
  #
  def new_statements(possible_statements,considered_statements)
        
    # TODO  I imagine there is a nicer way of doing this method using Procs or 
    #       passing blocks.
         
    results = StatementGroup.new
    possible_statements.each do |x|
      
      # Declare the statement that is being considered - for block statements
      # e.g. test.each do |x| only the "test.each" bit is considered
      if x.kind_of?(BlockStatement)
        subject = x.opening_statement
      end                
      subject ||= x                 

      catch(:already_exists) do
        considered_statements.each do |y|
          
          if y.kind_of?(BlockStatement)
            other = y.opening_statement
          end
          other ||= y

          catch(:different_from_this_statement) do
            
            # Checks whether the statements are equivalent
            if subject.equivalent?(other)
              throw :already_exists
            end
            throw :different_from_this_statement 
          end
        end
        results.push(x)
      end
    end
    return results
  end
  
  # Return the next set of available statements given the 
  # elements avialable.
  #
  def next_statements(available=[])
    
    # Collect a number of runtime variables 
    results = StatementGroup.new
    statement_structures.each do |structure|
      results += structure.statements(available)
    end    
    return results
  end
  
  # Retuns a runtime method instance that is the starting 
  # point when generating unique variable journeys.
  #
  def create_entrance_method
    return RuntimeMethod.new(MethodUsage.new,NilVariable.new)      
  end
  
  # Returns an array of potential statement structures
  # e.g.
  # 
  # Structure.new(Unknown,Equal,FixnumVariable,Addition,FixnumVariable)
  # 
  # TODO  Write more tests for StatementStructure2
  # TODO  I don't know if I want to declare the structures here.  It might be
  #       nicer to keep them with the variables.  They need to be with the variables
  #       since even if they were created by the same StatementStrucutre this is 
  #       no guarantee that they will have the same the structure. e..g
  #
  #       var_a.push(var_b);
  #
  def statement_structures
    return @default_structures
  end    
  
  # Returns the current runtime class instance 
  def to_runtime_class
    runtime_class = RuntimeClass.new(class_name)
    @runtime_methods.each do |x|
      runtime_class.push x.copy
    end    
    runtime_class.push @entrance_method
    return runtime_class
  end
  
  # Returns an array of statements that need 
  # DEPENDENCY - check ruby code
  # TODO  Look up Matrix in ruby p694
  def requisite_statements_for(entrance_method,statement,journeys)
    statement.required_variable_ids.each do |x|
      journeys[x].each do |y|
        entrance_method.push(y)
      end
    end    
  end 
  
  # Returns an array of statements based on the available variables and 
  # previously created statements.
  # 
  def create_statements(available,dependencies,vessel)     
    
    # Now attempt to create statements with each of the elements      
    statements = next_statements(available)

    # Remove out of scope dependencies
    # If a statement is used in a new scope it should be considered a new statement
    # NOTE For now I wont allow this

    # Remove statements that may have been considered at previous itteration
    statements = new_statements(statements,dependencies)    
    
    # Remove any statements that simple declare an existing variable var_a = var_b
    # TODO  With better structures this shouldn't be necessary
    statements = statements.remove_simple          

    return statements
  end
  
  # Returns an updated array of variables thats scope is with 
  # the tolerance specified.
  # 
  # @param  available     A array of available variables
  # @param  scope         An array indicating the scope to allow e.g. 
  #                       [5,7].
  #
  def filter_within_scope(available,scope)
    results = available.find_all {|x| scope.any?{|y| x.scope_id==y} }
    return results 
  end
  
  # Returns an array of statements in the order of their depenence.  
  #
  # @param  dependencies    A statement dependencies instance containing the 
  #                         depenency structure.    
  # @param  statement       The most recently added statement that's depenencies
  #                         need found for.
  # 
  def find_prerequisite_statements(dependencies,statement)

    # TODO  Call this method within dependencies
    # Find the dependcies for the statement - the last one is the current statement
    required_ids = dependencies.tsort_for_statement(statement)
    required_ids.pop
    
    # Add the dependent statements            
    results = []
    required_ids.each do |y|
      dependencies.each do |z|
        results.push(z.copy) if z.statement_id == y 
      end
    end    
    return results
    
  end
  
  # Strips out all the variables that are used as part of the 
  # the nested statements.  This is to avoid editing variables 
  # that are being itterated over.  For example
  # 
  # var_a = ['test']   
  # var_a.each do |x|
  #   var_a.push('test')
  # end
  #
  # @param  vars          An array of in-scope variables (relative to the supplied vessel)
  # @param  vessel        The nested statement or method thats structure is being considered
  # @param  dependencies  The dependencey structure of all the statements.
  # 
  def strip_dependent_variables(vars,vessel,dependencies)
    # Go through each nested statement in scope and remove any variables used in the statemnet
    # this is to prevent variables being itterated over being used in the nested statement.
    nested_statements = dependencies.find_all {|x| x.kind_of?(BlockStatement)}
    vessel.scope.each do |used_scope|
      nested_statement = nested_statements.detect {|x| x.scope_id == used_scope}
      next if nested_statement.nil?
      
      # Find the id of the variable used in the nested statement and remove it as a in_scope_variables
      # TODO  This presumes allot about the position of the variable in the statement
      vars.delete_if {|x| x.kind_of?(Variable) && x.variable_id == nested_statement.opening_statement.first.variable.variable_id }
    end
    return vars
  end
  
  # Returns an array of possible new statements given the currently 
  # available variables, scope limitations and statement dependencies. 
  #
  # @param  vessel        A vessel is something that contains statements.  This 
  #                       is either a nested statement or a runtime method.
  # @param  available     Is an array of all the variables and method calls.  Note
  #                       this has not been tailored to suit the vessel so some
  #                       of the variables shouldn't be available.
  # @param  dependencies  A statement dependencies instance that maintains what statements
  #                       are dependent on what.
  #
  def find_possible_new_statements(vessel,available,dependencies)

    # Filter the array of available variables to only include those within scope. 
    in_scope_variables = filter_within_scope(available,vessel.scope)
      
    # Strip out parent itterating variables 
    in_scope_variables = strip_dependent_variables(in_scope_variables,vessel,dependencies)

    # Create statements with the available variables  
    new_statement_results = create_statements(in_scope_variables,dependencies,vessel)    

    # All new statements should have the statement level of the vessel scope_id
    new_statement_results.each {|x| x.statement_level = vessel.scope_id}        
    
    return new_statement_results
    
  end
  
  # Returns an updated method that includes a specified statement and 
  # all of its dependencies in the correct order and depth.
  #
  # @param  initial_method
  #
  def build_minimalist_method(initial_method,statement,dependencies)

    # Find all the pre-requisite statements for the leading statement
    prerequisite_statements = find_prerequisite_statements(dependencies,statement)                  

    # Create an empty initial method to contain each arrangement
    constructing_method = initial_method.copy
    constructing_method.clear          

    # Add all the statement in their scope order
    prerequisite_statements.copy.each do |remaining_statement|
      unless remaining_statement.statement_level == constructing_method.scope_id
        
        # Find the pre-requiste statement the statement should reside in
        actual_statement = prerequisite_statements.delete_if {|z| z.statement_id == remaining_statement.statement_id}
        
        prerequisite_statements.each do |h|
          if h.kind_of?(StatementGroup)
            if h.scope_id == actual_statement.statement_level
              h.push(actual_statement)
              break
            end
          end
        end
        exit
      end
    end
    
    # Add each pre-requisite statement to the copied method
    prerequisite_statements.each do |f|
      constructing_method.push(f)
    end
    
    # Find the statement with the correct statement level and add the new statement
    container_statement = constructing_method.find_container_at_level(statement.statement_level)
    container_statement.push(statement)
    
    return constructing_method
        
  end
     
end
