# This class represents the code of a method generated at runitme
# 
# This a variation on code set that contains usage and a return 
# variable.  It shouldn't contain any other runtime methods
# since you can't write methods within methods.
#
class RuntimeMethod < StatementGroup
  include ActsAsTrackable
  include ActsAsRuntimeMethod
  
  attr_reader :method_id, :method_return, :usage
  attr_writer :method_id
    
  
  alias :statement_group_push :array_push
  
  @@METHOD_ID = 0
  
  # TODO  I'm still not sure how to handle the method usage - a runtime method by default 
  #       doesn't have literal values since it depends what it is like in each case.
  #
  # @param  usage           How the method should be used - this usage issue needs re-thought
  #                         for now the only requirement is for usage.length to equal 
  #                         parameters.length
  # @param  method_return   The response variable to return or nil if nothing is returned
  #
  #def initialize(usage,method_return=nil,*statements)
  def initialize(usage,method_id=nil,*statements)      
    super(*statements)
    
    # Set the method id for the generated method
    if method_id.nil?
      @@METHOD_ID += 1
      method_id = @@METHOD_ID
    end 
    @method_id = method_id
    
    # Save how the method should be used
    @usage = usage
    @scope_variables = []

    if method_return.nil? then method_return = NilVariable.new end
    @method_return = method_return
    
    # Set the statement level for runtime method (always - because it is the lowest depth)
    @statement_level = 0
    
  end
  
  #
  def self.reset_global_id
    #http://www.zenspider.com/Languages/Ruby/QuickRef.html
    unless $".include?('test/unit.rb')
      StandardLogger.log 'WARNING: Resetting variable id, this should only be done for tests'
    end
    @@METHOD_ID = 0
  end  

  # 
  def method_id=(id)
    
    # Only let this method be called from fellow RuntimeMethod classes
    # TODO  Test this prevents the method_id from being set non runtime method class
    unless caller.first.split(':')[0]==__FILE__
      raise StandardError.new('Attempting to set method_id')
    end
    @method_id = id
  end
  
  def reset_ids!
    copied_method = copy
    copied_method.method_id = '0'
    unique_variable_ids = variables.collect {|x| x.variable_id}.uniq
    reset_variable_ids = (0...unique_variable_ids.length)
    mapping = {}
    unique_variable_ids.zip(reset_variable_ids.to_a) do |var_id,reset_id|
      mapping[var_id] = reset_id
    end
    
    method_parameters = []
    @usage.each do |x|
      method_parameters.push(MethodParameter.new(mapping[x.variable_id]))
    end
    usage = MethodUsage.new(*method_parameters)
    
    copied_method.usage = usage
    
    replacement_mapping = {}
    mapping.each do |var_id,reset_id|
      replacement_mapping[var_id] = Unknown.new(reset_id)
    end
    
    copied_method.each do |statement|
      replacement_mapping.each do |var_id,value|
        statement.subst_variable!(var_id,value)
      end
    end
    
    copied_method
  end
  
  def variables
    return @usage
  end
  
  # Returns an array of variables that are available at a particular line
  # in the method.
  # 
  # TODO  This needs tests written for it especially for nested statements
  #
  def available_variable_at(params,line=0)
    reduced_copy = copy.clear
    self.each_with_index do |x,i|
      break if i > line  
      reduced_copy.push x.copy
    end
    return reduced_copy.available_variables(params)
  end
  
  # NOTE: This doesn't handle the case when there are two unknowns -
  #       dependent on each other.  e.g. 5 = var1+var2
  def find_next_unknown(complete_statements,concept)
    
    # If there are no unknown variables then the concept if fine to use
    if concept.unknown_count == 0 
      complete_statements.push(concept)
      return
    end

    concept.each_unknown do |unknown|
      
      # Go through each of the varialbes and see if they could be the unknown
      available_variables.each do |var|

        # Attempt to substitute one variable for another
        updated_concept = concept.subst(unknown.variable_id,var)
        next if updated_concept.nil?    
        
        # Find any further unknown variables in the statement
        find_next_unknown(complete_statements,updated_concept)
        
      end
      
      # Actually only look for the first unknown  
      return
    end
    
  end
    
  # TODO  This is temporary    
  def params
    return usage
  end    
  
  # Inserts a statement at a particular position within the runtime method.  This
  # could be at the root of the runtime method or within one of its statement
  # groups.
  # 
  def add_statement_at(statement,position)
    if position == self.statement_id
      push(statement)
      return
    end
    statement_groups = self.select_all {|x| x.kind_of?(StatementGroup) && x.statement_id == position}
    unless statement_groups.empty?
      statement_groups.first.push(statement)
      return
    end
    raise StandardError.new('The is no statement group with the id '+position.to_s)
  end    
  
  # Returns true if all the test cases when run through this runtime
  # method return the correct value. 
  #
  def all_pass?(test_cases)
    test_cases.each do |x|
      result = MethodEvaluation.new.evaluate_method(self.copy,x[:params].collect {|y| y.to_literal})
      return false unless result == x[:output]
    end
    return true
  end    
  
  def pass?(test_case)
    result = MethodEvaluation.new.evaluate_method(self.copy,test_case[:params].collect {|y| y.to_literal})
    return false unless result == test_case[:output]
    return true
  end
    
  def push(statement)
    
    # Confirms that supplied statement is a statement
    unless statement.kind_of? Statement or statement.kind_of?(StatementGroup)
      raise StandardError.new('Only statements can be included in a runtime method not '+statement.class.to_s)
    end
    
    # Check if the statement creates a new variable - and add it the available variables
    if statement.kind_of? DeclarationStatement
      @scope_variables.push(statement.declared)
      
      # The variable in the statement needs to have its requirements updated
  
    end

    #if statement.kind_of?(StatementGroup)
    if statement.class.to_s == 'StatementGroup'
      statement.each do |x|
        statement_group_push(x)
      end
    else
    
      # Adding statement to array 
      statement_group_push(statement)
    end
    
  end
   
  #
  #
  # @param  found_variables   
  # @param  statement         The statement that contains the solution.  It should be
  #                           in the following format:
  #                           return_var = var or return_var = var.<method_call>
  # @param  rule
  #
  def build_solution(found_variables,statement,rule)
    
    # Create the return statement
    return_statement = Statement.new
    return_statement.push Return.new
    
    #new_statement = statement.copy
    
    # Check the statement follows a "x = y" structure
    unless statement.assignment? then raise StandardError.new('Statement needs to inlcude an "="') end
    
    # Check whether any of the variables are unknown
    statement.each_unknown do |unknown|

        # Check if any of the unknown variables have been found
        #unless found_variables[unknown.variable_id.to_s].nil?
        if found_variables.has_key?(unknown.variable_id.to_s)  
          
          # Select the first possible variable id
          match_variable_id = found_variables[unknown.variable_id.to_s].first
              
          # Get the right hand side of the statement
          rhs =  statement.right_hand_side

          unless rhs.length == 1 then raise StandardError.new('Only expecting one right hand side element') end
          
          case rhs.first.class.to_s
            when 'InstanceCallContainer'
              
              # Does the subject of the call match?
              if found_variables.has_key? rhs.first.subject.variable_id.to_s
                
                # Replace unknown variable with the known one
                variables(rule) do |v|
                  if v.variable_id == found_variables[rhs.first.subject.variable_id.to_s].first
                    return_statement.push InstanceCallContainer.new(v.copy,rhs.first.method_call)
                    return return_statement
                  end
                end
              end
              
            when 'Unknown'  
              
              # Look through the variables 
              if found_variables.has_key? rhs.first.variable_id.to_s
                
                variables(rule) do |v|
                  
                  if v.variable_id == found_variables[rhs.first.variable_id.to_s].first
                    return_statement.push v.copy
                    return return_statement
                  end
                  
                end
                
              end
              
          else
            raise StandardError.new('Unexpected class '+rhs.first.class.to_s)
          end
          
        end
          
      end
        
      raise StandardError.new('Unable to find variable with matching id')
    
  end
  
  # Creates a copy of the method with the same usage and
  # statements but a different id.  I'm not sure if
  # should be using the same id or not.
  #
  def copy
    return Marshal.load(Marshal.dump(self))
#    # Create the copied method  
#    empty_copy = copy_base
#    empty_copy.method_id = @method_id
#    empty_copy.scope_id = scope_id
#    empty_copy.scope = scope
#    empty_copy.statement_level = statement_level    
#    self.each do |statement|
#      empty_copy.push(statement.copy)
#    end
#    
#    return empty_copy
  end  
  
  # Returns the total number of statements within the method.  Note 
  #  This includes the statements within nested statements.
  #
  def statement_count
    return self.inject(0) {|count, x| count += x.statement_count}
  end
  
  # Returns a dupicate method but only with the statements
  # up to the line given.
  #
  def partial_method(line)
    
    # Create a copy of the base runtime method
    x = copy_base
    
    # Check the length of method 
    if(line>statement_count) then raise MethodSizeError.new('Attmpting to create partial method larger than actual method - crazy bastard!') end
    
    # Now add statements up until the line limit has been met
    index = 0
    limit = Array.new(line)

    while(limit.length>0)
      if self[index].kind_of?(Statement)
        x.push(self[index].copy)
        limit.pop
        index += 1            
      elsif self[index].kind_of?(BlockStatement)
        x.push(self[index].partial(limit))
        index += 1
      else
        raise StandardError.new('Unexpected class type '+self[index].class.to_s)
      end
     
    end
    
    return x
  end

  # Returns a duplicate method but without any statements in it
  #
  def copy_base     
    copied_method = RuntimeMethod.new(@usage.copy,method_id) 
    return copied_method
  end      
  
  # Adds a new statement to the method that returns a variable
  # with the specified id.
  #
  # @param  id    The id of the variable that a return statement is being created
  #               for. 
  #
  def add_return_variable_statement!(id)        
    
    # Find the requested variable         
    var = contextual_variable(id)         

    # Create the return statement and add it
    self.push(Statement.new(Return.new,var))
    
  end
   
  # Returns a describtion of the method and the variables
  # within it.
  # 
  # TODO  Write test for this method
  #   
  def describe
    line = write+"\n"
    available_variables.each do |var|
      line += var.describe(self)
    end
    return line
  end
  
  # Searches through each statement and identifies whether they
  # override an existing variable or not.  
  #
  def identify_overriding_statements(params)
    previously_declared_variables = params.collect {|x| {:variable_id=>x.variable_id} }
    self.each do |x|
      x.identify_overriding_statements(previously_declared_variables)
    end
  end
  
  # Returns a statement that declares the runtime method instance.
  # e.g. RuntimeMethod.new(MethodUsage.new,ResponseVariable.new)
  #
  def declaration_statement    
    new_runtime_method = ClassMethodCallContainer.new(
                            RuntimeMethodClass.new,
                            New.new,
                            @usage.declaration_statement
    )
    return Statement.new(new_runtime_method)
  end
  
  # Evaluates the method but includes a return statement for the variable
  # thats id is specified.   
  #
  def literal_value_of_var(id,params)
    
    # Create a copy of the runtime method
    copied = self.copy
    
    # Find a reference to the variable in the method's statements and parameters
    var = nil
    # TODO  Remove all the @parameters
    params.each do |param|
      var = param if(param.variable_id == id)
    end
    if var.nil?
      copy.each do |statement|
        begin 
          var = statement.find_variable(id)
        rescue FailedToFindVariableError 
          next
        end
        break
      end
    end        
        
    if(var.nil?) then raise FailedToFindVariableError.new('Couldn\'t find variable with the id:'+id.to_s) end
    
    # Create a return statement for the requested variable
    copied.push(Statement.new(Return.new,var))
            
    # Now use the method to determine its value at runtime
    result = MethodEvaluation.new.evaluate_method(copied,params)    
    return result
        
  end  
  
  # Searches the paramaters for a variable with the specified id
  def find_variable_in_parameters(id)
    no_var_error = Proc.new { raise FailedToFindVariableError.new('Unable to find variable with the id '+id.to_s)  }
    return @usage.find(no_var_error){|i| i.variable_id == id}.copy    
  end
  
  # Returns an array of statements with a number of method calls
  # added to it that are equivalent to the variable specified.
  #
  # So a number of statements is provided and a say a string variable.
  # A number method call is added to each statement where the method
  # call will also return a string variable.
  #
  def replace_statement_element_with_method_calls(statements,variable,available=[])
    
    updated_statements = []

    if @method_return.meets_requirements?(variable)
                
      # Find potential method calls and include them as partial statements
      callable_combinations(available).each do |x|
        statements.each do |y|
          copied_statement = y.copy
          copied_statement.push(x)
          updated_statements.push(copied_statement)
        end
      end
    end       
    return updated_statements
  end

  # Returns an array of def calls given the code elements made 
  # available.
  #
  # @param  available   An array of possible paramaters for the method call
  #
  def callable_combinations(available=[])
    
    # Handle the case where the method doesn't require any parameters
    if @usage.empty? 
      return [DefCall.new(@method_return.copy,self.copy)]
    end
    
    # NOTE This assumes that all the paramaters must be populated
    
    # Go thorugh each usage method variable and construct arranges for each paramater
    # So if the method expects two parameters - say a string and a number you might
    # have variables.
    # A, B
    # C, B
    arrangements = [[]]
    @usage.each do |method_variable| 
      extended_arrangements = []
      arrangements.each do |existing_arrangement|
        available.each do |x|
          if method_variable.meets_requirements?(x)
              arrangement = existing_arrangement.copy
              arrangement.push(x)
              extended_arrangements.push(arrangement)
          end
        end
      end
      arrangements = extended_arrangements.copy
    end
    
    # Convert the arrangements to DefCalls
    def_calls = []
    arrangements.each do |x|
      def_calls.push(DefCall.new(@method_return.copy,self.copy,*x))
    end
    return def_calls
    
  end
  
  # Returns an array of possible statements that contain
  # a call to this runtime method.
  #
  def usage_statements(available=[])
    results = []
    def_calls = callable_combinations(available)
    def_calls.each do |x|
      # TODO  Unknown variables should be replaced
      results.push Statement.new(Var)
    end
  end
  
  # Returns the runtime methods as a RuntimeMethodParameter.  
  #
  # @param  id    The id of the variable to give to the returned method
  #               variable.
  #
  def to_var(id=nil,uniq_id=nil)
    var = RuntimeMethodParameter.new(self.copy) {{:variable_id => id,:uniq_id=>uniq_id}}
    # TODO  This means that global variable_id is increamented when it doesn't need to be
    var.variable_id = id unless id.nil?    
    return var
  end
  
  # Returns a history object reflecting how the runtime method
  # is processed.
  #
  # @param  params                An array of realised variables
  # @param  additional_methods    An array of add
  #
  def history(params,additional_methods=[])

    # Check the number of parameters to method usage
    raise StandardError.new('Incorrect number of parameters') unless params.length == @usage.length
    
    # Create the method that changes are logged to
    instance_tracking_variable = ArrayVariable.new
    instance_tracking_variable.instance_variable = true
    tracking_method = RuntimeTrackingMethod.new(instance_tracking_variable)

    # Duplicate the current method and add tracking calls
    copied = self.copy.trackify(params,tracking_method)
    
    # Create a method to call the method and return the results
    process_method = RuntimeMethod.new(MethodUsage.new)
    track_statement = Statement.new( DefCall.new(NilVariable.new,copied,*params.collect {|x|  x.value} ) )
    process_method << track_statement
    return_statement = Statement.new( Return.new,instance_tracking_variable )
    process_method << return_statement

    # Evaluate the method
    # TODO  This might need to have a number pre-fixed (I'm not certain it's overwritten)
    # runtime_class = RuntimeClass.new('Temporary'+rand(1000).to_s,tracking_method,copied,process_method,*additional_methods)
    runtime_class = RuntimeClass.new('Temporary',tracking_method,copied,process_method,*additional_methods)  
    result = ClassEvaluation.new.evaluate_class(runtime_class,process_method.method_name)
    return result 
  end
  
  # Proxy for the history method except it expects to receive an array of literals.    
  # 
  # TODO  Probably best to change the real history method to use literals
  #
  def history2(params,additional_methods=[])
    
    if(params.any? {|x| x.kind_of?(Variable)})
      raise StandardError.new('Currently only literal values can be realised')
    end
    
    # TODO  Is KnownVariable a better name than LiteralVariable
    # Convert the passed paramters into literal variables with the appropriate ids
    unless usage.length == params.length
      raise StandardError.new('This method expects '+usage.length.to_s+' param(s) but '+params.length.to_s+' were passed')
    end
    realised_params = []
    usage.zip(params).each do |x,y|
      realised_params.push y.to_var(x.variable_id,x.uniq_id)
    end    
    
    return history(realised_params,methods)
  end
  
  # Returns an updated method that includes a method call 
  # after each statement to monitor the usage of a runtime method.
  # 
  # @param  tracking_method     A runtime tracking method instance that the track calls
  #                             saved to.
  #
  def trackify(params,tracking_method)
    
    # TODO  Really need to give the tracking method parameter proper names - and get them in
    #       correct order.
    
    # Identify what statements are overridden to inform what variables need tracked
    identify_overriding_statements(params)
    
    line = []
    copied = copy_base    
    modified_params = params

    # Start by adding the initial tracking call - to catch the parameters
    # CONTINUE: tracking the statement_id
    initial_tracking_statement = tracking_statement(
        tracking_method,
        line,
        self.statement_id.to_literal,        
        abstract_variables_for_tracking(modified_params)
    )      
    copied.push(initial_tracking_statement)

    # TODO  Currently I am collect all the variables in the variable container -be that 
    #       a nested statement or a single statment.  I don't know what variables I 
    #       actually need to retain.

    # Create an array to update the variable ids to suite the method usage
    # TODO  I'm not sure this is needed any more
    id_conversion = Hash.new
    @usage.zip(params) do |x,y|
      new_var = y.copy
      new_var.variable_id = x.variable_id
      new_var.uniq_id = x.uniq_id
      id_conversion[x.uniq_id.to_s.to_sym] = new_var
    end  
    
    # Copy the runtime method and update each statement
    copy.each_with_index do |x,i|
      if x.kind_of?(Statement)
        
        # Update the ids of the variables used in the statement to use the ids of the method usage
        #duplicated_statement = x.exchange_variables(id_conversion)
        duplicated_statement = x.copy
        variable_values = abstract_variables_for_tracking(duplicated_statement)
        copied.push(duplicated_statement)
        copied.push(
          tracking_statement(
            tracking_method,
              line,
              duplicated_statement.statement_id,
              variable_values,
              duplicated_statement
          )
        )
        # TODO  I think this has to be a OpenStatement
      elsif(x.kind_of?(StatementGroup))
      
        # Retrieve tha variables available at the point before the nested statement opens
        results = []
        available_variable_at(params,line.length).each do |y|
          # TODO  I should change these to symbols 
          results.push(Hash['id'=>y.variable_id,'value'=>InstanceCallContainer.new(y,Copy.new)])
        end        
        
        # Retrieve the nested statement and trackify it
        trackifyied_nested_statement = x.trackify(
          tracking_method,line
        )
        copied.push(trackifyied_nested_statement)
        
        # Add the tracking call for after the statement (this has the id for the whole nested statement)
        
        # Retrieve the variables used in the nested statement - excluding those no longer in scope
        # TODO  I should maybe only be concerned with the variables that change in the nested 
        #       statement.
        # containers = [x.opening_statement]+x.each 
        
        # Search through the nested statement for all the statements that override a variable
        # TODO  It really should be all the variables that are overridden and available
        #       outside the nested statement.
        variable_values = abstract_variables_for_tracking(*x.find_overriding_statements)
        
        # TODO  The only variables recorded here are ones that overriden inside the nested statement
        copied.push( 
          tracking_statement(
            tracking_method,
              line,
              self.statement_id,
              variable_values,
              x
          ) 
        )
        
        # TODO  I think I'm going to give nested statements two ids - one outside
        #       one inside.  I might use the internal statment id as one and the
        #       actual nested statement as the other.
      else
        raise StandardError.new('Unexpected class '+x.class.to_s)
      end
     
   end
    return copied
  end
  
  # Rebuilds the method with TypeVariables that all have literal
  # values.
  #
  # @param  params              A param container instance that contains the necessary parameters for the
  #                             runtime method instance.
  # @param  params                [UPDATE] This is being changed to except only an array of literal
  #                               values e.g. 'tests', 9, <#SomeObject>.  This will be converted into 
  #                               a literal variable within the method.
  #
  # @param  additional_methods  An array of any methods that are required by the runtime method instance
  #
  # TODO  I expect "params" could probably be changed from a paramaters container to an 
  #       array of literal values.
  # 
  def realise2(params,additional_methods=[])
    
    # TEMP
    if(params.any? {|x| x.kind_of?(Variable)})
      raise StandardError.new('Currently only literal values can be realised')
    end
    
    # TODO  Is KnownVariable a better name than LiteralVariable
    # Convert the passed paramters into literal variables with the appropriate ids
    unless usage.length == params.length  
      raise StandardError.new('This method expects '+usage.length.to_s+' param(s) but '+params.length.to_s+' were passed')
    end
    realised_params = []
    usage.zip(params).each do |x,y|
      realised_params.push y.to_var(x.variable_id,x.uniq_id)
    end
    
    # Check that any required runtime methods were supplied
    # TODO  Given that I can retrieve all the runtime methods from the statements I probably shouldn't 
    #       bother passing them in as parameters to the method.
    find_all_required_runtime_methods.each do |x|
      missing_method = lambda{raise StandardError.new('Missing method with id '+x.method_id.to_s)}
      additional_methods.detect(missing_method) {|y| y.method_id == x.method_id}
    end

    # Retrieve a history object reflecting the use of the runtime method    
    past = history(realised_params,additional_methods)

    # Create a realised method instance to return
    realised_runtime_method = RealisedRuntimeMethod.new(realised_params)
    realised_runtime_method.method_id = @method_id
        
    # Go through each statement and substitue any of the variables
    # for those in the history object
    self.each do |x|
      if x.realised?
        realised_runtime_method.push(x)
        next
      end

      # Handle nested and single statements differently      
      if(x.kind_of?(Statement))        
        realised_statement = x.realise2(past)
        realised_runtime_method.push(realised_statement)
      elsif(x.kind_of?(BlockStatement))
        
        # TODO - TEMP DEBUG
        instance_tracking_variable = ArrayVariable.new
        instance_tracking_variable.instance_variable = true
        tracking_method = RuntimeTrackingMethod.new(instance_tracking_variable)        
        
        #resulting_method.push(x.realise2(past))
        realised_runtime_method.push(x.realise2(past))
        
        # TODO  I have just added this ---------------------08/02/2011 - I really need to go through the whole
        #       tracking thing.
      elsif(x.kind_of?(OpenStatement))
        
        # TODO - TEMP DEBUG
        instance_tracking_variable = ArrayVariable.new
        instance_tracking_variable.instance_variable = true
        tracking_method = RuntimeTrackingMethod.new(instance_tracking_variable)        
        
        #resulting_method.push(x.realise2(past))
        realised_runtime_method.push(x.realise2(past))
                
      else
        raise StandardError.new('Unexpected data type '+x.class.to_s)      
      end
      
    end
    
    realised_runtime_method.close
    return realised_runtime_method
    
  end
  
  def cauldron_method_calls
    return ['.all_pass?','.pass?','.history2','.last','.statement_id','.params','.realise2']
  end  
  
  def to_intrinsic
    return IntrinsicRuntimeMethod.new()
  end
  
protected
  
  def usage=(usage)
    @usage = usage
  end
  
end