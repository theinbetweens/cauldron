class TheoryGenerator
  
  def initialize(filters=[])
    @filters = filters
  end
  
  # Returns an array of master theories(huge theories) generated using the runtime 
  # method at each stage of the chain.
  #
  def master_theories(chain,initial_runtime_method,test_cases)
    raise StandardError.new('Currently only able to generate master theories for complete chains') unless chain.complete? 
    
    # Retrieve the full variable history for the chain - need to avoid duplicate variable creation especially if a variable 
    # only exists in the action.
    creation_history = chain.variables_creation(initial_runtime_method,test_cases)
    
    #   * Create the values array [{:value=>x,:statement=>:step=>}]
    master_theories = []
    chain.each_theory_progression(initial_runtime_method,test_cases) do |implemented_theory,theory|
          
      dependent_accessors = retrieve_accessors(implemented_theory.accessor_values[:before],creation_history)
      result_accessors = retrieve_accessors(implemented_theory.accessor_values[:after],creation_history)
      
      # Generate the dependents and results
      theory_dependents = get_theory_dependents(dependent_accessors.copy)[0..8]
      theory_results = get_theory_dependents(result_accessors.copy)[0..2]
      
      # Create the complete theory
      master_theories << Theory.new(
        theory_dependents.copy,
        theory.action.copy,
        theory_results
      )
      
    end
    return master_theories
    
  end
  
  # Returns a master and simplistic theory in conext of the supplied runtime
  # method after each of the actions is added.  So for each action there is 
  # new theory generated.
  #
  # NOTE: This is the first time I've started to introduce this master/simply 
  #       theory paradigm.  The general rule I'm using is that the simple theory
  #       only needs to be complex enough so it can indicate the order the actions
  #       should be performed.
  # 
  # NOTE: The variables that each of theories use always refer to the same value.  So
  #       if var1 is the rutime method then var1 is the runtime method for all the theories.
  #
  def generate_theories_for_actions(runtime_method,test_cases,actions)
    
  end
  
  # Returns true if adding the supplied actions to the runtime method results 
  # in all the tests cases being met.  This is useful to use before attempting
  # to generate the theories to solve the test cases. 
  #
  # TODO  I would rather the mapping was ChainMapping or ideally the mapping wasn't passed 
  #       all, just have it as internal to the chain. 
  #
  def actions_validate_runtime_method?(runtime_method,test_cases,actions,mapping)
    
    # Declare the default finish for any problem
    head = Theory.new([],nil,[])
    tail = Parser.run("if(runtime_method.all_pass?(test_cases))\nreturn true\nend")
    
    # Create the chain 
    chain = Chain.new
    chain.form_chain(head,tail,mapping)
    
    # Add each of the actions to the chain
    actions.each do |action|
      chain.add_link(Theory.new([],action,[]))
    end
    
    # Implement the chain so that all variables are unified
    implementd_chain = chain.implement
    
  end
  
  # This generates an inital set of theories using the initial values.  It
  # then continues to generate additional theories after applying the action 
  # of the previously generated theories.
  #
  def multiple_generate(runtime_method,test_cases,limit=1)
    theories = generate(test_cases,runtime_method,0)

    additional_theories = []
    theories.each_with_index do |x,i|
      additional_theories += recursive_generate(test_cases,x,1,(limit-1))
    end      
    return theories+additional_theories
    
  end
  
  def recursive_generate(test_cases,theory,stage,limit=1,results=[])
    
    results << theory
    return results if limit == 0
    
    # TODO  It seems a bit wasteful to generate a whole new set of accessors for each
    #       new theory.  It should maybe just up accessors that include the runtime method.
    new_theories = generate(test_cases.copy,theory.example_runtime_method.copy,stage)
    
    new_theories.each do |x|
      recursive_generate(test_cases.copy,x,(stage+1),(limit-1),results)
    end
    return results
  
  end
  
  # Returns an array of theories that add a variety of statements to the runtime
  # method.  The theories will be quite bloated since they'll contain all the possible
  # dependents and results.
  #
  # @param  values    An array of literal values 
  #
  def generate(test_cases,runtime_method,stage=0)
   
    # 
    # TODO  Not keen on this parallel assignment (should really just 
    #       have a single instance containing the accessors and 
    #       mapping or have the mappig generated)
    accessors, mapping = generate_accessors_and_mapping(test_cases,runtime_method,4,stage)
    
    # Now generate some possible theories using these values
    return generate_theories(test_cases,runtime_method,accessors,mapping)
    
  end
  
  # Returns an array of statements that use the values supplied but will return a 
  # value(including boolean).
  #
  def generate_accessors_and_mapping(test_cases,runtime_method,itterations=1,stage=0)
    
    # TODO  I'd like to drop this and just query the mapping instance
    theory_variable_ids = [0,1,2]

    # Create a theory variable for each of the values
    # runtime_method => 1
    # test_cases => 2    
    mapping = Mapping.new({
      1 => runtime_method.copy,
      2 => test_cases.copy
    })
    results = [
      {:value=>runtime_method.copy,:statement=>TheoryStatement.new(TheoryVariable.new(1)),:step=>0},
      {:value=>test_cases.copy,:statement=>TheoryStatement.new(TheoryVariable.new(2)),:step=>0}
    ]
    
    # Generate a number of values that can be obtained from the current runtime method and test cases
    itterations.times do |step|    
      results = extend_accessors(results,mapping,theory_variable_ids,(step+1))
    end
    return results, mapping
      
  end
  
  def generate_theories(test_cases,runtime_method,accessors,mapping)
    
    # Retreive theory dependets relating to the current method
    theory_dependents = get_theory_dependents(accessors.copy)
    
    # Retrieve possible statements to include in the theory
    theory_actions = get_theory_action(test_cases.copy,runtime_method.copy,accessors,mapping)
    
    # For each action retrieve the results of adding the statement
    theories = []
    theory_actions.each_with_index do |selected_action,i|
      
      # Add the statement to the runtime method and construct result theories based on it
      new_values = accessors.copy
      
      # Convert the mapping values into intrinsic values
      intrinsic_mapping = covert_to_intrinsic_mapping(mapping)      
      
      # Re-create the action with intrinsic variables
      implementated_action = selected_action.map_to(intrinsic_mapping)
      
      # Generate the runtime method that would be created by using that action
      modified_runtime_method = TheoryChainValidator.new.add_statement_to_method(
        test_cases.copy,
        runtime_method.copy,
        implementated_action
      )

      # TODO  I should maybe keep both runtime methods so the I can compare the runtime method's
      #       before and after.

      # Create a new mapping using the update runtime method
      new_mapping = mapping.copy
      new_mapping[1] = modified_runtime_method
      
      # Re-build the results but using the new value for the runtime method
      # re_evaluate_results
      # TODO  Using the same result statements is limiting  - there might be more calls available.
      new_results = re_evaluate_results(accessors,new_mapping)
      
      # Get the theory results for this modified runtime method
      theory_results = get_theory_results(new_results)

      # Create the complete theory
      theories << Theory.new(
        theory_dependents.copy,
        selected_action,
        theory_results,
        modified_runtime_method
      )
      
    end      
    
    return theories      
    
  end
  
  def get_theory_action(test_cases,runtime_method,results,mapping)
    
    # Get possible statements ids
    statement_ids =  results.select {|x| x[:value].kind_of?(Fixnum)}
    
    actions = []
    
    # Add 'return <val>' statement
    results.each do |x|
      statement_ids.each do |y|
        # TODO  Shouldn't allow runtime methods to be included here
        actions << TheoryAction.new(
          TheoryStatement.new(StringToTheory.run("Statement.new(Return.new,#{x[:statement].write})")),
          StringToTheory.run(y[:statement].write)
        )
      end
    end
    # Add the 'if(var1 == var2)' statement
    # TODO  Might only allow values in the action at this point
    # 'IfStatement.new(var2[var3][:params][var6],Equivalent.new,var2[var3][:output])'
    # TODO  Should the values be equal at this point??
    
    # Exclude the runtime method from being included as a value (.write method becomes messy)
    # also excludes the orginal test_cases.
    valid_results = results.select do |x|
      
      # TODO  For some reason "x[:value].all? {|y| y.kind_of?(CTestCase)}" returns true for method Parameter (which is why this is here)
      next true if x[:value].kind_of?(MethodParameter)
      
      next false if x[:value].kind_of?(RuntimeMethod)
      
      # NOTE: This is only temporary - I don't really see anything wrong with nil
      next false if x[:value].kind_of?(NilClass)
      
      next false if x[:value].kind_of?(Array) && x[:value].all? {|y| y.kind_of?(CTestCase)}
      next true
    end
    
    (results-valid_results).each do |x|
      next if x[:value].nil?
    end
    
    # Generate "if(varA == varB) statements"
    value_pairs = valid_results.permutation(2)
    value_pairs.each do |x,y|
      statement_ids.each do |z|
        
        # if(x == y)
        # COMPROMISE - Only include statements with the same data type
        # TODO  They should be same type not identical so as long as the extend Array
        # TODO  I need to get the value of the runtime method parameter e.g. 'var2.params[var5]'
        if x[:value].class != MethodParameter and y[:value].class != MethodParameter
          next unless x[:value].class == y[:value].class
        end
        actions << TheoryAction.new(
          TheoryStatement.new(
            StringToTheory.run(
              "OpenStatement.new(Statement.new(If.new,Container.new(#{x[:statement].write},Equivalent.new,#{y[:statement].write})))"
            )
          ),
          StringToTheory.run(z[:statement].write)
        )  
      end
    end

    # TODO  I haven't allowed last_runtime_method to be used yet
    
    # ========================================================
    # Remove the actions that don't work
    # ========================================================
    # TODO  This duplicates the the "covert_to_intrinsic_mapping" method
    # Convert the mapping values into intrinsic values
    intrinsic_mapping = Mapping.new    
    test_cases_key = nil
    runtime_method_key = nil
    mapping.each do |key,value|
        
      # Convert fixnum into intrinisic fixnums
      if value.kind_of?(Fixnum)
        intrinsic_mapping[key] = IntrinsicLiteral.new(value)
        next
      end
      
    end
    intrinsic_mapping[1] = Parser.run('runtime_method')
    intrinsic_mapping[2] = Parser.run('test_cases') 
    
    # Attempt to add the statement to the actual runtime method
    valid_actions = []
    actions.each do |x|
      implementation = x.map_to(intrinsic_mapping)
      if action_works_with_runtime_method?(test_cases.copy,runtime_method.copy,implementation)
        valid_actions << x
      end
    end
    
    return valid_actions
    
  end
  
  def covert_to_intrinsic_mapping(mapping)
    
    # Convert the mapping values into intrinsic values
    intrinsic_mapping = Mapping.new    
    test_cases_key = nil
    runtime_method_key = nil
    mapping.each do |key,value|
        
      # Convert fixnum into intrinisic fixnums
      if value.kind_of?(Fixnum)
        intrinsic_mapping[key] = IntrinsicLiteral.new(value)
        next
      end
      
      if value.kind_of?(RuntimeMethod)
        intrinsic_mapping[key] = Parser.run('runtime_method') 
        runtime_method_key = key
        next
      end
      
      if value.kind_of?(Array) && value.first.has_key?(:params)
        intrinsic_mapping[key] = Parser.run('test_cases')
        test_cases_key = key
        next
      end
      raise StandardError.new('Unknown value '+value.class.to_s)
    end
    return intrinsic_mapping
  end
  
  # Attempt to use the generated action with the runtime method to determine if
  # it's valid syntax.  
  #
  def action_works_with_runtime_method?(test_cases,runtime_method,action)
    return TheoryChainValidator.new.add_statement_to_method(test_cases,runtime_method,action) ? true : false
  rescue StandardError => e
    return false
  end
  
  # Returns an array of theory dependents 
  #
  def get_theory_dependents(results)
    
    # Create the theory dependents for all the values
    value_pairs = results.permutation(2)
    theory_dependents = []
    value_pairs.each do |x,y|
      if x[:value] == y[:value]
        theory_dependents << TheoryDependent.new(
          StringToTheory.run("if(#{x[:statement].write} == #{y[:statement].write})\nreturn true\nend")
        )
      else
        theory_dependents << TheoryDependent.new(
          StringToTheory.run("if((#{x[:statement].write} == #{y[:statement].write})==false)\nreturn true\nend")
        )
      end
    end    
    return theory_dependents
  end
  
  def get_theory_results(results)
    theory_results = []
    
    # Create the single statement theory results
    results.each do |x|
      if x[:value]
        theory_results << TheoryResult.new(
          StringToTheory.run("if(#{x[:statement].write})\nreturn true\nend")
        )
      elsif x[:value] == false
        theory_results << TheoryResult.new(
          StringToTheory.run("if((#{x[:statement].write})==false)\nreturn true\nend")
        )
      else
        StandardLogger.instance.error(x[:statement].write+' is '+x[:value].to_s)
      end
      # TODO  Should probably have else x[:value].nil? and StringToTheory.run("if((#{x[:statement].write}).nil?)\nreturn true\nend") 
    end
    
    # Create the theory dependents for all the values
    value_pairs = results.permutation(2)
    value_pairs.each do |x,y|
      if x[:value] == y[:value]
        theory_results << TheoryResult.new(
          StringToTheory.run("if(#{x[:statement].write} == #{y[:statement].write})\nreturn true\nend")
        )
      else
        theory_results << TheoryResult.new(
          StringToTheory.run("if((#{x[:statement].write} == #{y[:statement].write})==false)\nreturn true\nend")
        )
      end
    end    
    return theory_results    
    
  end
  
  # Re-evaluate the values of each of the results using an updated 
  # runtime method instance.
  #
  def re_evaluate_results(results,mapping)
    new_results = []
    results.each do |x|
      v = obtain_value(x[:statement],mapping)
      new_results << {:value=>v,:statement=>x[:statement],:step=>x[:step]}    
    end
    return new_results
  end
  
  # Extends the provided accessors by another method call.  For example
  # if it is passed "test", it would return 'test'.length and
  # 'test'.lowercase etc.  
  #
  # @param  initial_accessors     An array of initial accessors containing the statement used
  #                               to generate the value and the value itself.
  #                               {:value=>#<Some Literal Value>,:statement=><#Statement: A statement instance>}  
  # @param  mapping               The current mapping being used.  This is extended when a new 
  #                               index is used.  So if test_case[0] is used, then 0 needs to have
  #                               variable created for it and that added to the mapping.
  # @param  variable_history      This keeps track of each time a new variable is created via additional
  #                               array access calls.  This allows the structure of the theories to remain
  #                               unified across the dependents and results.
  #   
  def extend_accessors(values,mapping,theory_variable_id,step,variable_history=[])
    
    # Go through each of the values and get each of the cauldron method calls
    total_results = []
    values.each do |x|

      # Get the possible cauldron method calls
      results = []
      x[:value].cauldron_method_calls.each do |y|

          # Only get array access for values obtained in the last itteration
          if (step-1) == x[:step]
            results += params_output(x,y,mapping,theory_variable_id,step,values)
            results += array_access(x,y,mapping,theory_variable_id,step,values,variable_history)
          end
          
          # If the variable is new it should have all the paramters
          # If it isn't new it only needs the recent params

          # Only include parameters for recently created values
          if (step-1) == x[:step]
            results += use_method_call(x,y,mapping,theory_variable_id,step,values)
          else
            last_results = values.select {|z| z[:step] == (step-1)}
            results += use_method_call(x,y,mapping,theory_variable_id,step,last_results,true)
          end        
        
      end 
      total_results += results  
    end
    return total_results+values
  end
  
  #
  #
  #
  def use_method_call(result,cauldron_method_call,mapping,theory_variable_id,step,available_params,params_only=false)
    
    # Does it start with a '.'
    results = []
    if cauldron_method_call =~ /^\./
      
      # Does it require any parameters
      if ['.any?','.all_pass?','.pass?','.history2','.realise2','.kind_of?'].include?(cauldron_method_call)
        
        case cauldron_method_call
          when '.pass?'
            # Uses one parameter - a test case
            cauldron_test_cases = available_params.select {|x| x[:value].kind_of?(CTestCase)}
            cauldron_test_cases.each do |x|
              s = TheoryStatement.new(
                StringToTheory.run(result[:statement].write+cauldron_method_call+'('+x[:statement].write+')')
              )
              v = obtain_value(s,mapping)
              results << {:value=>v,:statement=>s,:step=>step}
            end
          when '.kind_of?'
            
            # TODO  Should probably include value class check here
            s = TheoryStatement.new(
              StringToTheory.run(result[:statement].write+cauldron_method_call+'(CTestCase)')
            )
            v = obtain_value(s,mapping)
            results << {:value=>v,:statement=>s,:step=>step}
            
            s2 = TheoryStatement.new(
              StringToTheory.run(result[:statement].write+cauldron_method_call+'(Fixnum)')
            )
            v2 = obtain_value(s,mapping)
            results << {:value=>v2,:statement=>s2,:step=>step}            
          when '.all_pass?'
            
            available_params.each do |x|
              if x[:value].kind_of?(Array) and x[:value].any? {|y| y.kind_of?(CTestCase)}
                s = TheoryStatement.new(
                  StringToTheory.run(
                    result[:statement].write+cauldron_method_call+'('+x[:statement].write+')'
                  )
                )
                v = obtain_value(s,mapping)
                results << {:value=>v,:statement=>s,:step=>step}    
              end
            end
            
          when '.history2'
            return []
            cauldron_arrays = available_params.select {|x| x[:value].kind_of?(Array)}
            cauldron_test_case_params = cauldron_arrays.select {|x| x[:statement].write.include?(':params')}
            cauldron_test_case_params.each do |x|
              s = TheoryStatement.new(
                StringToTheory.run(result[:statement].write+cauldron_method_call+'('+x[:statement].write+')')
              )
              v = obtain_value(s,mapping)
              results << {:value=>v,:statement=>s,:step=>step}
            end
          when '.realise2'
            cauldron_arrays = available_params.select {|x| x[:value].kind_of?(Array)}
            cauldron_test_case_params = cauldron_arrays.select {|x| x[:statement].write =~ /:params\]$/}
            cauldron_test_case_params.each do |x|
              s = TheoryStatement.new(
                StringToTheory.run(result[:statement].write+cauldron_method_call+'('+x[:statement].write+')')
              )
              v = obtain_value(s,mapping)
              results << {:value=>v,:statement=>s,:step=>step}
            end
          when '.any?'
            return []
            # if(var5.history2(var2[var3][:params]).any?{ |x| x['statement_id'] == var1.last.statement_id} )
            if result[:value].kind_of?(Array)
              available_params.each do |x|
                # TODO  Should probably only match values of the same type - I don't want 
                #       var1.any?{|x| x == var2.pass?(var1[var4])}
                
                # Only allow one block statement - 
                next if x[:statement].write.include?('{')
                
                # TODO  I should reduce the number of possible comparisons 
                #       (there is no point in comparing things will never be the same) 
                s = TheoryStatement.new(
                  StringToTheory.run(
                    result[:statement].write+cauldron_method_call+'{|x| x == '+x[:statement].write+'}'
                  )
                )
                v = obtain_value(s,mapping)    
                results << {:value=>v,:statement=>s,:step=>step}
              end
              
              # TODO  This is is a quick hack to get x[:statement] included - down the line it might
              #       require a separate extend_accessors call.
              if(result[:value].first.class==Step)
                result[:value].first.cauldron_method_calls.each do |x|
                  
                  available_params.each do |y|
                    
                    # Only allow one block statement - 
                    next if y[:statement].write.include?('{')                    
                    
                    s = TheoryStatement.new(
                      StringToTheory.run(
                        result[:statement].write+cauldron_method_call+'{|x| x'+x+' == '+y[:statement].write+'}'
                      )
                    )
                    v = obtain_value(s,mapping)                       
                    
                    results << {:value=>v,:statement=>s,:step=>step}
                    
                  end
                end
              end
              
            else
              raise StandardError.new("Not setup for call '#{cauldron_method_call}'")
            end
        else
          raise StandardError.new("Not setup for call '#{cauldron_method_call}'")
        end
        
        # NOTE: These don't take parameters
      elsif ['.length','.last','.statement_id','.params','.value'].include?(cauldron_method_call)
        
        # Don't include this call if only parameter calls are being considered
        return [] if params_only
        
        s = TheoryStatement.new(StringToTheory.run(result[:statement].write+cauldron_method_call))
        v = obtain_value(s,mapping)
        results << {
          :value=>v,
          :statement=>s,
          :step=>step,
          :intrinsic_statement=>self.convert_to_intrinsic_statement(s,mapping)
        }
      else
        raise StandardError.new('Unknown method '+cauldron_method_call)
      end
    end    
    return results
  end
  
  def params_output(result,cauldron_method_call,mapping,theory_variable_id,step,results=[])
    results = []
    if cauldron_method_call.include?('[:params]') or cauldron_method_call.include?('[:output]')
      s = TheoryStatement.new(StringToTheory.run(result[:statement].write+cauldron_method_call))
      v = obtain_value(s,mapping)
      results << {:value=>v,:statement=>s,:step=>step}
    end    
    return results
  end
  
  # TODO  Why is results passed through if it is just overwritten?
  def array_access(result,cauldron_method_call,mapping,theory_variable_ids,step,results=[],variable_history=[])
    
    results = []
    if cauldron_method_call == '[]'
      if result[:value].length > 4 then raise StandardError.new('Cauldron has not been tested with arrays larger that 4') end
        
      # Generate theory variables for each of the new accessors
      array_indexs = []    
      result[:value].length.times do |z|
        
        theory_id = theory_variable_ids.length
        
#        TODO Taking this complexity out for now.       
#        # Find pre-exisitng variables of the same value
#        # TODO    I should make sure I don't include unessary values here - I should check 
#        #         that the same array access has not already been included indirectly in
#        #         via the action. var2, var3 both refer to same fixnum for case 1
#        existing_variables = mapping.select{|key,value| value == z}
#        array_indexs += existing_variables.collect {|key,value|  TheoryVariable.new(key)}
        
        # Before adding a new variable - check that an existing one doesn't already exist
        
        #   * Generate the intrinsic statement for it
        new_written_intrinsic_statement = result[:intrinsic_statement].write+'['+z.to_s+']'
        # TODO  I might be able to use the results instead for the variable history now that I'm
        #       saving the intrinsic_statement
        if variable_history.any? { |x| new_written_intrinsic_statement == x[:intrinsic_statement].write }
          StandardLogger.instance.warning('Identical array access already exists '+new_written_intrinsic_statement)
          saved_variable = variable_history.find {|x| x[:intrinsic_statement].write == new_written_intrinsic_statement}
          
          #mapping[saved_variable[:global_variable_id]] = saved_variable[:variable_value].value
          mapping[saved_variable[:global_variable_id]] = z
          array_indexs << TheoryVariable.new(saved_variable[:global_variable_id])
        else
         
          mapping[theory_id] = z
          array_indexs << TheoryVariable.new(theory_id)
          theory_variable_ids << theory_variable_ids.length
        end
      end
      
      # Generate a statement for each of the calls
      array_indexs.each do |z|
        s = TheoryStatement.new(StringToTheory.run(result[:statement].write+'['+z.write+']'))
        v = obtain_value(s,mapping)
        var_ids = s.variables.collect {|a| a.theory_variable_id}
        var_values = var_ids.collect {|a| mapping[a]}
        results << {
          :value=>v,
          :statement=>s,
          :step=>step,
          :variable_values=>var_values,
          :intrinsic_statement=>convert_to_intrinsic_statement(s,mapping)
        }
   
        # Save the array history as well
        unless variable_history.any? {|x| x[:global_variable_id] == z.theory_variable_id}
          
          variable_history << {
            :intrinsic_statement=>convert_to_intrinsic_statement(s,mapping),
            :written_statement=>s.write,
            :variable_value=>var_values.last.to_intrinsic,
            :global_variable_id=>z.theory_variable_id
          }
          #raise StandardError.new('This array index has not been saved in the history '+z.theory_variable_id.to_s)
          
        end
        
      end
    end        
    return results
    
  end
  
  def obtain_value(statement,mapping)
    
    # Declare each of the theory variables with the correct value
    declaration = ''
    mapping.each do |key,value|
      declaration += 'var'+key.to_s+' = mapping['+key.to_s+']'+"\n"
    end
    eval(declaration)
    return eval(statement.write)
      
  end
  
protected  
  
  def retrieve_accessors(literal_values,variable_creation_history)
    value_accessors = []
    a = literal_values.copy
    literal_values.each do |key,val|
      s = TheoryStatement.new(StringToTheory.run('var'+key.to_s))
      value_accessors << {
        :value=>val.copy,
        :statement=>s,
        :variable_values=>[val.copy],
        :step=>0,
        :intrinsic_statement=>convert_to_intrinsic_statement(s.copy,a.copy)
      }
    end
    step = 0
    
    array_of_variable_ids = literal_values.keys.copy
    # TODO  Hate the fact that mapping is modified via 'extend_accessors'
    mapping = literal_values.copy

    2.times do
      value_accessors = self.extend_accessors(  value_accessors, 
                                                mapping, 
                                                array_of_variable_ids, 
                                                (step+1),
                                                variable_creation_history
                                              )
                                              step += 1
    end    
    
    return value_accessors
  end 
  
  # Converts the theory statement to an intrinsic statement.
  #  
  def convert_to_intrinsic_statement(theory_statement,literal_values)
    intrinsic_values = literal_values.inject({}) {|total,(key,value)| total[key] = value.to_intrinsic; total}
    intrinsic_statement = theory_statement.map_to(intrinsic_values)
    return intrinsic_statement
  end
  
end 