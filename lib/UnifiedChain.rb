# A unified chain is no longer editable - all the links have been added.  Unlike a normal 
# chain there is no mapping, all the theories should have the correct ids if they are 
# linked.  A unified chain is always complete.
#
class UnifiedChain

  attr_reader :connections

  def initialize(nodes,connections)
    @nodes = nodes
    #pp connections
    
    @connections = connections
    @variable_keys = connections.mapping.keys
    #pp @variable_keys
    
    raise StandardError.new('chain is not complete ') unless self.complete?
  end
  
  def write(tab=0)
    return @nodes.inject('') {|total,x| total += x.write}
  end
  
  def describe(tab=0)
    return @nodes.inject('') {|total,x| total += x.describe}
  end
  
  def copy
    #return Chain.new(@nodes.copy)
    return Marshal.load(Marshal.dump(self))
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
    
    # puts '-------------------------------'
    # puts Cauldron::Util::Saver.save(runtime_method)
    # puts Cauldron::Util::Saver.save(test_cases)
    # puts '-------------------------------'
    # Get the initially available intrinsic values
    intrinsic_values = [IntrinsicRuntimeMethod.new,IntrinsicTestCases.new]
    
    total_variables = self.theory_variables.length
    
    available_values = [IntrinsicRuntimeMethod.new,IntrinsicTestCases.new]    
  
    valid_mappings = [{}]
    
    itteration_limit = 9
    
    @nodes.each_with_index do |node,index|
      
      valid_mappings = extend_value_mapping_wtih_dependents(
                          valid_mappings,
                          index,
                          node,
                          available_values,
                          test_cases.copy,
                          runtime_method.copy
                        )
      
      unless node.action.nil?
        if index == 0
          chain = partial_chain(1..0)
        else
          chain = partial_chain(1..(index-1))  
        end
        limit = 0            
        until has_all_variables_been_found?(node.action,valid_mappings) or limit > itteration_limit
          valid_mappings = extend_mapping(valid_mappings,node.action,runtime_method.copy,test_cases.copy,chain,available_values)
          limit += 1
        end
        if limit > itteration_limit  
          puts 'Chain saved '+Cauldron::Util::Saver.save(self)
          puts 'Is chain complete: '+complete?.to_s
          raise StandardError.new('Unable to resolve action: '+"\n"+node.action.write)
        end        
      end
      
      valid_mappings = extend_value_mapping_with_result(valid_mappings,index,node,available_values,test_cases.copy,runtime_method.copy)
      
    end
      
    return valid_mappings.collect {|x| Mapping.new(x)} 
    
  end
  
  def extend_value_mapping_with_result(valid_mappings,index,node,available_values,test_cases,runtime_method)
    itteration_limit = 3
    node.results.each do |result|
      chain = partial_chain(0..index)
      limit = 0            
      until has_all_variables_been_found?(result,valid_mappings) or limit > itteration_limit
        valid_mappings = extend_mapping(valid_mappings,result,runtime_method.copy,test_cases.copy,chain,available_values)
        limit += 1
      end
    end    
    return valid_mappings
  end
  
  def extend_value_mapping_wtih_dependents(valid_mappings,index,node,available_values,test_cases,runtime_method)
    itteration_limit = 6
    node.dependents.each do |dependent|
      if index == 0
        chain = partial_chain(0..0)
      else
        chain = partial_chain(1..(index-1)) 
      end
      limit = 0
      until has_all_variables_been_found?(dependent,valid_mappings) or limit > itteration_limit
        valid_mappings = extend_mapping(valid_mappings,dependent,runtime_method.copy,test_cases.copy,chain,available_values)
        limit += 1
      end  
    end    
    return valid_mappings
  end
  
  def has_all_variables_been_found?(component,mappings)
    component.theory_variables.each do |var|
      mappings.each do |m|
        return false unless m.has_key?(var.theory_variable_id)
      end
    end
    return true
  end
  
  def extend_mapping(valid_mappings,component,runtime_method,test_cases,chain,available_values)
    
    new_mappings = [] 
    component.theory_variables.each do |var|
    
      valid_mappings.each do |mapping|

        implemented_chain = chain.implement(Mapping.new(mapping))
        implemented_runtime_method = TheoryChainValidator.new.build_method_from_chain(
                                        implemented_chain,runtime_method.copy,test_cases.copy
                                      )        

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
          valid_mappings = valid_mappings-[mapping]
          next
        end
        values = values.uniq      
        values.each do |value|
          copied_mapping = mapping.copy
          copied_mapping[var.theory_variable_id] = value
          new_mappings << copied_mapping 
        end
      end
      
    end
    # => QUICK Hack
    new_mappings = identify_uniq_mappings(new_mappings)
    longest_mapping = new_mappings.inject(0) do |highest,m| 
      if(m.length > highest) 
        highest = m.length
      end
      highest
    end
    res = new_mappings.select {|x| x.length == longest_mapping}
    new_mappings = res
    
    unless new_mappings.empty?
      valid_mappings = new_mappings
    end
    return valid_mappings    
    
  end
  
  def identify_uniq_mappings(mappings)
    uniq_mappings = []
    count = mappings.length
    until mappings.empty?
      mapping = mappings.shift
      already_exists = mappings.any? do |x|
        next false unless x.length == mapping.length
        next false unless x.keys.sort == mapping.keys.sort
        all_values_the_same = true 
        x.each do |key,value|
          if mapping[key].class != value.class
            all_values_the_same = false
          end 
          if mapping[key].class == value.class
            if mapping[key].kind_of?(IntrinsicLiteral)
              if mapping[key].write != value.write
                all_values_the_same = false
              end
            end
          end
        end
        next false unless all_values_the_same
        next true
      end
      unless already_exists
        uniq_mappings << mapping
      end
    end
    if uniq_mappings.length == 0 && count != 0
      raise StandardError.new('uniq_mappings should not be 0')
    end
    return uniq_mappings
  end
  
  def intrinsic_values_for_variable(id,component,mapping,runtime_method,test_cases,intrinsic_values)
    
    values = []
    component.statements_with_variable(id).each do |statement|
      reg = eval('/^var'+id.to_s+'\./')
        if statement.write.match(reg)
        
        intrinsic_values.each do |value|
          temp_mapping = mapping.copy
          temp_mapping[id] = value
          # => TODO Not validating the component - e.g. if(var1.kind_of?(RuntimeMethod))
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
      values += variable_values      
      
    end
    return values
  end
  
  def partial_chain(range)
    links = @nodes[range].collect {|x| x.copy }
    PartialChain.new(links)
  end
  
  # => TODO This might not be need - use cucumber to check
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
  end    
  
  # TODO  This is a temporary method while I work out how incomplete? chains are being created
  def complete?
    @nodes.each do |node|

      # Exclude the current node being considered
      filtered_nodes = TheoryCollection.new(@nodes.copy - [node])
      
      node.dependents.each do |dependent|
        unless filtered_nodes.results.any? {|result| result.write == dependent.write}
          return false
        end        
      end
      
    end
    return true
  end
  
end