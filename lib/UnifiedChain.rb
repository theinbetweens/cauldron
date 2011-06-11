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
    return ImplementedChain.new(implemented_nodes)
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
    
    # Determine the number of variables without intrinsic values
    theory_variable_ids = theory_variables.collect {|x| x.theory_variable_id}
    
    # Collect the theory variables without intrinsic values
    missing_intrinsic_values = theory_variable_ids-mapping.keys
    
    # Take the first theory and identify all the accessors
    # (need to work out what is the runtime method and what the test cases)
    
    # TEMP: Why are these implemented theories
    @nodes.first.all_theory_variables
    
    # Create the theory generator
    generator = TheoryGenerator.new()
    accessors, temp_mapping = generator.generate_accessors_and_mapping(test_cases,runtime_method,1)
    if temp_mapping.length > missing_intrinsic_values.length

      # Now to assign real values to the chain
      
      # Apply the values in the various permutaions 
      # (this is very crude and means that odd calls )
      theory_variable_ids = @nodes.first.all_theory_variables.collect {|x| x.theory_variable_id }
      
      # Get the posible sets for values in an array so that non of the arrays contain all the same values
      res = temp_mapping.values.collect {|x| x}
      
      # TODO  This is a complete hack but I think I should be using intrinsic values rather than real
      intrinsic_res = res.collect {|x| x.to_intrinsic}
      value_permutaions = intrinsic_res.permutation(theory_variable_ids.length).to_a
      uniq_value_permutations = value_permutaions.collect {|x| x.to_set}.uniq
      
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