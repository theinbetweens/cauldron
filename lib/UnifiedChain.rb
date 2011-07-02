# A unified chain is no longer editable - all the links have been added.  Unlike a normal 
# chain there is no mapping, all the theories should have the correct ids if they are 
# linked.  A unified chain is always complete.
#
class UnifiedChain < Chain
  # TODO  I don't like that extending to Chain exposes the @nodes to public access
  
  def initialize(nodes)
    @nodes = nodes
  end
  
  def write(tab=0)
    return @nodes.inject('') {|total,x| total += x.write}
  end
  
  def describe(tab=0)
    return @nodes.inject('') {|total,x| total += x.describe}
  end
  
  # Returns an array of all the theory variables in the chain.  All the 
  # theory variables should be global across the chain. 
  #
  def theory_variables
    results = @nodes.inject([]) do |total,theory|
      total += theory.all_theory_variables.collect {|x| x}
      total
    end
    return results.uniq
  end
  
  # Return an implemented version of the chain where all the theory variables have
  # been replaced with read values.
  #
  def implement(mapping)
    implemented_nodes = @nodes.inject([]) do |total,theory|
      total << theory.map_to(mapping)
    end
    return ImplementedChain.new(implemented_nodes,mapping)
  end

  def implementation_permuatations2(runtime_method,test_cases,mapping)

    more_mapping = valid_mapping_permutations(runtime_method.copy,test_cases.copy)

    return more_mapping.inject([]) { |total,mapping| total << self.copy.implement(mapping) }
    
  end
  
  def valid_mapping_permutations(runtime_method,test_cases)
    
    # Get the initially available intrinsic values
    intrinsic_values = [IntrinsicRuntimeMethod.new,IntrinsicTestCases.new]
    
    total_variables = self.theory_variables.length
    puts 'Total Variables: '+total_variables.to_s
    
    available_values = [IntrinsicRuntimeMethod.new,IntrinsicTestCases.new]    
    
    valid_mappings = [Mapping.new]
    
    @nodes.each_with_index do |node,index|
      puts 'Starting node: '+index.to_s
      puts 'node.dependents.length: '+node.dependents.length.to_s
      node.dependents.each do |dependent|
        if index == 0
          chain = runtime_method.copy
        else
          chain = partial_chain(index-1) 
        end
        valid_mappings = extend_mapping(valid_mappings,dependent,runtime_method.copy,test_cases.copy,chain,available_values)  
      end
      
      unless node.action.nil?
        puts 'node.action: '+node.action.class.to_s
        if index == 0
          chain = runtime_method.copy
        else
          chain = partial_chain(index-1) 
        end            
        puts node.action.write
        valid_mappings = extend_mapping(valid_mappings,node.action,runtime_method.copy,test_cases.copy,chain,available_values)
      end
      
      puts 'node.results.length: '+node.results.length.to_s
      node.results.each do |result|
        chain = partial_chain(index) 
        valid_mappings = extend_mapping(valid_mappings,result,runtime_method.copy,test_cases.copy,chain,available_values)
        pp valid_mappings
      end
      
    end
      
    
    
    chain = partial_chain(0)    
    valid_mappings = extend_mapping(valid_mappings,@nodes[1].action,runtime_method.copy,test_cases.copy,chain,available_values)
    pp valid_mappings
    valid_mappings = extend_mapping(valid_mappings,@nodes[1].action,runtime_method.copy,test_cases.copy,chain,available_values)
    pp valid_mappings
    @nodes[1].results.each do |result|
      valid_mappings = extend_mapping(valid_mappings,result,runtime_method.copy,test_cases.copy,chain,available_values)
    end
    return valid_mappings.collect {|x| Mapping.new(x)} 
    
  end
  
  def extend_mapping(valid_mappings,component,runtime_method,test_cases,chain,available_values)
    
    new_mappings = [] 
    component.theory_variables.each do |var|
      next if valid_mappings.first.has_key?(var.theory_variable_id)
      valid_mappings.each do |mapping|

        
        implemented_chain = chain.implement(Mapping.new(mapping))
        implemented_runtime_method = TheoryChainValidator.new.build_method_from_chain(implemented_chain,runtime_method.copy,test_cases.copy)        
        
        possible_values = available_values-mapping.values    
        
        begin 
        values = intrinsic_values_for_variable(
          var.theory_variable_id,
          component,
          mapping,
          implemented_runtime_method,
          test_cases.copy,
          possible_values    
        )
        rescue NoMethodError => e
          puts e
          puts valid_mappings.length
          valid_mappings = valid_mappings-[mapping]
          puts valid_mappings.length
          next
        end
        values = values.uniq      
         values.each do |value|
           valid_mappings.each do |mapping|
             copied_mapping = mapping.copy
             copied_mapping[var.theory_variable_id] = value
             new_mappings << copied_mapping 
           end
         end
       end
    end
    unless new_mappings.empty?
      valid_mappings = new_mappings
    end
    return valid_mappings    
    
  end
  
  def intrinsic_values_for_variable(id,component,mapping,runtime_method,test_cases,intrinsic_values)
    #intrinsic_values = [IntrinsicRuntimeMethod.new,IntrinsicTestCases.new]
    
    values = []
    component.statements_with_variable(id).each do |statement|
      reg = eval('/^var'+id.to_s+'\./')
        if statement.write.match(reg)
        
        intrinsic_values.each do |value|
          temp_mapping = mapping.copy
          temp_mapping[id] = value
          if valid_mapping?(runtime_method.copy,test_cases.copy,statement,temp_mapping)
            values << value
          end
        end
        next
      end
      # values for index
      index_values = []
      intrinsic_statement = statement.map_to(mapping)
      if intrinsic_statement.select_all {|z| z.kind_of?(TheoryVariable)}.length > 0
        if m = intrinsic_statement.write.match(/([\w\.]+)\[var(\d)+\]/)
          method_call = $1
          if m2 = method_call.match(/var(\d+)/)
            next 
          end
          literal = evaluate_statement(method_call,runtime_method.copy,test_cases.copy)
          literal.length.times do |n|
            index_values << IntrinsicLiteral.new(n)
          end        
        end    
      end      
      values += index_values
      
      #variable_values = []
      #result.statements_with_variable(var.theory_variable_id).each do |statement|
      #variable_values += values_for_variable_as_argument(var,statement,mapping,intrinsic_values,implemented_runtime_method.copy,test_cases.copy)
      #end
      #values += variable_values
      
      #intrinsic_statement = statement.map_to(mapping)
      variable_values = []
      intrinsic_values.each do |value|
        literal = intrinsic_statement.write.gsub(/var(\d)+/,value.write)
        begin
          eval literal
          variable_values << value
        rescue
          next
        end
      end
      #return results
      values += variable_values      
      
      
    end
    return values
  end
  
  def partial_chain(limit)
    links = @nodes[1..limit].collect {|x| x.copy }
    UnifiedChain.new(links)    
  end
  
  def mapping_permutations(keys,values)
    values.permutation(keys.length).to_a.inject([]) do |total,value_permutation|
      total << Hash[*keys.zip(value_permutation).flatten]
    end
  end
  
  def valid_mapping?(runtime_method,test_cases,statement,mapping)
    intrinsic_statement = statement.map_to(mapping)
    return false unless intrinsic_statement.select_all {|z| z.kind_of?(TheoryVariable)}.length == 0
    valid_statement?(intrinsic_statement,runtime_method.copy,test_cases.copy)
  end
  
  def evaluate_statement(statement,runtime_method,test_cases)
    eval statement
  end
  
  def valid_statement?(statement,runtime_method,test_cases)
    eval statement.write
    return true
  rescue NoMethodError
    return false    
  end
  
  # Returns an array of implemented chains using the various value
  # permutations.  Essential what it is looking for is mapping to convert 
  # all the theory variables to intrinsic variables.
  #
  # @param  runtime_method    The runtime method instance that will be populated to 
  #                           create the solution.<#RuntimeMethod >
  # @param  test_cases        The test cases instance containing real values.
  #
  def implementation_permuatations(runtime_method,test_cases,mapping)
    
    return implementation_permuatations2(runtime_method,test_cases,mapping)
    
    # Determine the number of variables without intrinsic values
    theory_variable_ids = theory_variables.collect {|x| x.theory_variable_id}
    
    # Collect the theory variables without intrinsic values
    missing_intrinsic_values = theory_variable_ids-mapping.keys
    
    # Take the first theory and identify all the accessors
    # (need to work out what is the runtime method and what the test cases)
    
    # TEMP: Why are these implemented theories
    # @nodes.first.all_theory_variables
    
    # Create the theory generator
    generator = TheoryGenerator.new()
    
    #accessors, temp_mapping = generator.generate_accessors_and_mapping(test_cases,runtime_method,1)
    accessors, temp_mapping = generator.generate_accessors_and_mapping(test_cases,runtime_method,3)

    if temp_mapping.length > missing_intrinsic_values.length

      # Now to assign real values to the chain
      
      # Apply the values in the various permutaions 
      # (this is very crude and means that odd calls )
      #theory_variable_ids = @nodes.first.all_theory_variables.collect {|x| x.theory_variable_id }
      
      theory_variable_ids = self.theory_variables.collect {|x| x.theory_variable_id }
      
      # Get the posible sets for values in an array so that non of the arrays contain all the same values
      res = temp_mapping.values.collect {|x| x}
      
      # TODO  This is a complete hack but I think I should be using intrinsic values rather than real
      intrinsic_res = res.collect {|x| x.to_intrinsic}
      value_permutaions = intrinsic_res.permutation(theory_variable_ids.length).to_a
      uniq_value_permutations = value_permutaions.collect {|x| x.to_set}.uniq
      puts 'uniq_value_permutations: '+uniq_value_permutations.length.to_s
      possible_mappings = []
      
      theory_variable_id_permutations = theory_variable_ids.permutation(theory_variable_ids.length).to_a
      
      possible_mappings = []
      theory_variable_id_permutations.each do |theory_variable_id_permutation|
        uniq_value_permutations.each do |value_permutation|
          m = Mapping.new
          theory_variable_id_permutation.zip(value_permutation.to_a) do |key,value|
            m[key] = value
          end
          possible_mappings << m
        end
        
      end
      
      # Implemented changes
      return possible_mappings.inject([]) { |total,mapping| total << self.copy.implement(mapping) }
      
    else
      raise StandardError.new('Could not generate enough real vlaues to test theory - try increasing the itterations')
    end
    
  end    
  
end