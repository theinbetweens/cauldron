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
    
    # Get the initially available intrinsic values
    intrinsic_values = [IntrinsicRuntimeMethod.new,IntrinsicTestCases.new]
    
    valid_mappings = []
    @nodes[1].action.theory_variables.each do |var|
      
      @nodes[1].action.statements_with_variable(var.theory_variable_id).each do |statement|
        reg = eval('/^var'+var.theory_variable_id.to_s+'\./')
        next unless statement.write.match(reg)
        
        mappings = mapping_permutations([var.theory_variable_id],intrinsic_values)
        
        mappings.each do |mapping|
          valid_mappings << mapping if valid_mapping?(runtime_method.copy,test_cases.copy,statement,mapping)
        end
        
      end
     
      
    end
    
    valid_mappings = valid_mappings.uniq 
    extended_mappings = []
     
    @nodes[1].action.theory_variables.each do |var|
      
      next if valid_mappings.first.has_key?(var.theory_variable_id)
      
      variable_values = []
      @nodes[1].action.statements_with_variable(var.theory_variable_id).each do |statement|  
        valid_mappings.each do |mapping|
          variable_values += values_for_variable(var,statement,mapping,runtime_method.copy,test_cases.copy)
        end
      end         
      variable_values = variable_values.uniq

      extended_mappings = []
      valid_mappings.each do |mapping|
        variable_values.each do |value|
          copied_mapping = mapping.copy
          copied_mapping[var.theory_variable_id] = IntrinsicLiteral.new(value)
          extended_mappings << copied_mapping
        end
      end
       
    end
    
    extended_mappings = extended_mappings.uniq
    
    chain_validator = TheoryChainValidator.new
    links = @nodes[1..1].collect {|x| x.copy }
    chain = UnifiedChain.new(links)
    chain.last.results = []
    more_mapping = []
    extended_mappings.each do |mapping|
      
      #puts chain.implement(Mapping.new(mapping)).describe
      implemented_chain = chain.implement(Mapping.new(mapping))
      implemented_runtime_method = TheoryChainValidator.new.build_method_from_chain(implemented_chain,runtime_method.copy,test_cases.copy)
      
      @nodes[1].results.each do |result|
        result.theory_variables.each do |var|
          next if valid_mappings.first.has_key?(var.theory_variable_id)
          
          # => Get the values for the variable
          variable_values = []
          result.statements_with_variable(var.theory_variable_id).each do |statement|
            variable_values += values_for_variable_as_argument(var,statement,mapping,intrinsic_values,implemented_runtime_method.copy,test_cases.copy)
          end
          
          variable_values.each do |value|
            temp_mapping = mapping.copy
            temp_mapping[var.theory_variable_id] = value
            more_mapping << temp_mapping
          end      
          
        end  
      end
      
    end

    more_mapping = more_mapping.collect {|x| Mapping.new(x)}
    return more_mapping.inject([]) { |total,mapping| total << self.copy.implement(mapping) }
    
  end
  
  def valid_mapping_permutations(runtime_method,test_cases)
    
  end
  
  def values_for_variable_as_argument(var,statement,mapping,values,runtime_method,test_cases)
    intrinsic_statement = statement.map_to(mapping)
    results = []
    values.each do |value|
      literal = intrinsic_statement.write.gsub(/var(\d)+/,value.write)
      begin
        eval literal
        results << value
      rescue
        next
      end
    end
    return results
  end
  
  def values_for_variable(var,statement,mapping,runtime_method,test_cases)
    results = []
    intrinsic_statement = statement.map_to(mapping)
    if intrinsic_statement.select_all {|z| z.kind_of?(TheoryVariable)}.length > 0
      if m = intrinsic_statement.write.match(/([\w\.]+)\[var(\d)+\]/)
        literal = evaluate_statement($1,runtime_method.copy,test_cases.copy)
        literal.length.times do |n|
          results << n
        end        
      end    
    end
    return results
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