
# Instances are expected to connect any number of theories so 
# that the chain finishes with a particular outcome.  
#
# e.g.  '<runtime_method>.all_pass?(<test_cases>) = true'
#
class TheoryConnector
  
  def initialize(potential_values)
    @potential_values = potential_values
  end
  
  # Attempts to chain the theories togeather so that the final theory
  # results in the specified "finish".
  #
  # @param  runtime_method    This is an instance of the core runtime method
  #                           instance that is populated with any number of statements.
  # @param  test_cases        An array of test cases that contain the values for 
  #                           runtime method's paramters and the expected return value
  #                           given those parameters.
  # @param  finish            A description of the desired final outcome - this will
  #                           probably be
  #                           '<runtime_method>.all_pass?(<test_cases>) = true'
  # @param  theories          A array of theories to be chained togeather to result 
  #                           in the finish outcome.   
  #
  # TODO Last runtime method dependencies can't be shared down the the theory chain 
  # 
  def chain(runtime_method,test_cases,finish,theories)
    
    return create_possible_chains(runtime_method,test_cases,finish,theories)
    
  end

  # NOTE: Will probably replace the create_possible_chains and chain call  
  # Returns an array of complete chains that conclude with a valid 
  # runtime method.
  #
  def generate_chains(runtime_method,test_cases,theories)
    
    # Create the inital chain (with the head and tail)
    intial_chain = Chain.new
    
    # Find a theory that can act as the head
    possible_head_theories = theories.select {|x| x.dependents.length == 0}
    
    # Create the initial chains
    possible_chains = []
    possible_head_theories.each do |x|
      possible_chains += intial_chain.copy.add_link(x)
    end
        
    # Check the initial chains incase they're complete
    complete_chains = []
    if possible_chains.any? {|x| x.complete? }
      complete_chains += possible_chains.select {|x| x.complete?}
      possible_chains.delete_if {|x| x.complete?}
    end       
    
    # Continue to add theories to the chains until they are complete or the theories are exhausted
    possible_chains.each do |x|
      
      # Remove the head theory to avoid it being re-used
      head_free_theories = theories.copy
      head_free_theories.delete_if {|theory| theory.theory_id == x.first.theory_id}

      complete_chains += extend_chain(x,head_free_theories)
    end
    return complete_chains
    
  end
  
  # TODO  Need to watch out here for infinite chain connections
  def extend_chain(chain,theories)
    complete_chains = []
    
    theories.each do |x|
      extended_chains = chain.copy.add_link(x)
      next if extended_chains.empty?
      
      # Don't allow the same theory to be added twice - for now
      updated_theories = theories.copy
      updated_theories.delete_if {|theory| theory.theory_id == x.theory_id}
      
      complete_chains += extended_chains.select {|y| y.complete?}
      extended_chains.delete_if {|y| y.complete?}
      extended_chains.each do |y|
        #complete_chains += extend_chain(y,theories)
        complete_chains += extend_chain(y,updated_theories)
      end
    end
    return complete_chains
  end

  def create_possible_chains(runtime_method,test_cases,finish,theories)
    
    # Generate the head theory - this is the starting point and doesn't have any dependents
    accessors, mapping = TheoryGenerator.new.generate_accessors_and_mapping(test_cases,runtime_method,7,0)
    
    # * Generate all the possible results of this runtime method
    theory_results = TheoryGenerator.new.get_theory_results(accessors)

    # * Create the actual head theory
    head_theory = Theory.new([],nil,theory_results,runtime_method.copy)
    
    # Create the initial chain that needs to be connected
    intial_chain = Chain.new
    intial_chain.form_chain(head_theory,finish,mapping)
    
    return create_possible_chain_extensions(runtime_method,test_cases,finish,theories,intial_chain)
  end

  # This method has been created so the initial chain can be passed in to start the method
  # creation.  Generating the initial chain can take a couple of minutes.
  #
  def create_possible_chain_extensions(runtime_method,test_cases,finish,theories,intial_chain)
    
    # Save any of the complete chains
    possible_chains = []
    
    # Search through the available theories and find one that results in the finish
    potential_final_theories = theories.select {|x| x.has_result_structure?(finish)}
    
    # Attempt to add the potential link to the end of the chain
    partial_chains = [] 
    potential_final_theories.each do |theory|
      potential_chain = intial_chain.copy
      # TODO  Maybe should be call add_link_to_tail - then check if it completes
      if(potential_chain.add_link(theory))
        # A new link has been added - does this complete the chain (tail -> head)
        res = potential_chain.complete?
        #if potential_chain.complete?
        if res
          possible_chains << potential_chain 
        else
          partial_chains << potential_chain
        end
      end
      
    end
    
    
    # If there are any partial chains try to extend them with additional theories
    # - partial chains were connect to the finish but not the head.
    partial_chains.each do |partial_chain|
      
      # Select from the chain the dependents that haven't be met.
      
      # TODO  This looks very messy - 

      # Take the first dependent attempt to add a theory to resolve it
      # - NOTE: This theory may resolve other of the dependents
      #until partial_chain.unmet_dependents.empty?
      limit = 1
      until partial_chain.unmet_dependents.empty? or limit == 0
        
        # Select the firs of the unment dependents
        dependent = partial_chain.unmet_dependents.first
        
        # Search through the available theories for ones that match the dependent structure
        # TODO  This should be empty for "ruby test/unit/theory/tc_theory_connector.rb --name test_chain_with_2_theories"
        potential_theories = theories.select {|x| x.has_result_structure?(dependent) }
        if potential_theories.length > 10
          raise StandardError.new("Have not tested for #{potential_theories.length.to_s} potential theories" )
        end
        
        # Attempt to add the theory to the partial chain (prefers the theories that complete)
        potential_theories.each do |t|
          updated_chain = partial_chain.copy
          # TODO  Should create a quick way to switch input on and off while the script is running
          if(updated_chain.add_link(t))
            partial_chain = updated_chain
            if updated_chain.complete?
              possible_chains << updated_chain
              break
            else
            end
          else
          end
        end        
        
        limit -= 1
      end
      
    end

    # Return the complete chains 
    return possible_chains    
    
  end
  
  # Returns a new chain so that they all use consistent theory variables ids
  #
  # @param  chain   An array of theories e.g.
  #                 [<#Theory>,<#Theory>,<#Theory>,<#Theory>]
  # 
  #                 The last chain contains the finished theory.
  #  
  # It is difficult to generate all the arrangements for the chain as soon as
  # there start to be a large number of dependents and results.  There is just too
  # many permutations.  Once any connection is decided upon e.g. this dependent to 
  # that result then the number of permutations is reduced.  As such they need to 
  # be updated in parallet.
  #
  # 
  #
  def unify_chain2(chain)
    
    unified_chains = []
    
    # Reverse the chain so that the finish is the first theory
    reversed_chain = chain.reverse
    
    # This method needs to map the theory variables used in one theory to the 
    # rest.  This basically means there is a global theory that has a respective
    # id in each of the other theories in the chain. e.g.
    #
    # +----------+--------+--------+--------+--------+
    # |Global #ID| link#1 | link#2 | link#3 | link#4 |
    # +----------+--------+--------+--------+--------+
    # |    0     |   1    |   1    |   2    |   89   |
    # +----------+--------+--------+--------+--------+
    # |    1     |   2    |   4    |   6    |   1    |
    # +----------+--------+--------+--------+--------+
    #
    
    # {global#ID=> #{link#1=>1,#link#2=>5}
    
    # Take the first theory and set the global theory variables to the first link
    global_theory_variables = {}
    
    # * Pop the first link in the chain and set ids of the theory variables
    link = chain.pop
    link.all_theory_variables.each do |theory_variable|
      
      # For the first link I'm just going to use the same id as the first link
      global_theory_variables[theory_variable.theory_variable_id] = {link.theory_id=>theory_variable.theory_variable_id}
      
    end
    
    # 1.  Find all the dependent-> result permutations for the last chain 
    # 2.  Exclude any that are mutually exclusive
    
    #possible_global_theory_variables = extend_global_mapping(global_theory_variables,link,chain)
    
    # NOTE: Previously I had normalised the theories by working out all the possible permutations 
    #       of dependent to result.  Then work out the variable substitution.  This did work but
    #       the number of permutations for larger theories meant it was completely impractical.  Instead
    #       now it needs to form one connection "dependent to result" and then update the consequence of
    #       that. Some of the decisions will be mutually exclusive. 
    
    return unified_chains
    
  end
  
  def extend_global_mapping(global_theory_variables,link,chain,results=[])
    
    next_link = chain.pop
    
    # Find all the variables in the next link thats global ids have not been determined
    unidentified_theory_variables = next_link.all_theory_variables.inject([]) do |total,x|
      total << x if global_theory_variables.any? {|key,value| !value[next_link.theory_id].nil? }
    end
    
    # Link the previous dependents to the this link
    link.dependents.each do |dependent|
      
      # Find the similar 
      
    end 
    
  end
  
  # Returns a new chain so that they all use consistent theory variables ids
  #
  def unify_chain(chain)
    
    #return unify_chain2(chain.reverse)
    
    # TODO  Break up this method and write tests for the individual parts

    # Find all the ways the theory and results can connected
    # - the same_structure? approach is quite loose
    arrangements = chain_arrangements(chain.copy.reverse)
    # For each theory in the chain give each each variable a unique id
    starting_id = 1
    uniq_chain = chain.inject([]) do |total,x|
      r = x.uniq_theory_variables(starting_id)
      starting_id = r.highest_theory_variable_id+1
      total << r
      total
    end
    
    # Identify the matching variables
    mappings = matching_variables(arrangements,uniq_chain)
    # TODO Why are so many of these identical
    mappings.uniq!
    
    # Identify opposed mapping (variables that don't match in the context of the theory aren't equal)
    false_mappings = {}
    uniq_chain.each do |x|
      r = x.all_theory_variables.collect {|x| x.theory_variable_id}
      r.each do |y|
        false_mappings[y] = r.copy.delete_if {|z| z == y}
      end
    end
    
    final_mapping = []
    #mappings = [mappings.last]
    
    count = 0
    mappings.each do |m|
      count += 1
      # Create an array of all variables that are equalivalent
      master = combine_matches(m.to_a)
      
      # Check that the equivalent variables don't occur in the same theory
      # TODO  If this never occurs I need to re-think things
      catch :bad_map do 
        false_mappings.each do |key,value|
          
          master.each do |x|
            if x.include?(key)
              if (x | value).length != x.length+value.length
                throw :bad_map
              end
            end
          end
        end
      
       final_mapping << master.collect {|x| x.uniq}
      end
    end
    
    # Generate new chains using the final mappings
    return [] if final_mapping.empty?
    
    #m = final_mapping.last
    new_chains = []
    final_mapping.each do |x|
      
      # Get the id of all the theory variables
      all_theory_variable_ids = uniq_chain.collect {|y| y.all_theory_variables.collect {|z| z.theory_variable_id} }.flatten
      
      # Unique theory variables
      uniq_variables = all_theory_variable_ids-x.flatten
      unique_count = (all_theory_variable_ids-x.flatten).length + x.length
      
      # Prepare the mapping to match each id to a new variable
      # (at this stage each of the mappings should be unique)
      map = Mapping.new
      unique_count.times do |k|
        unless uniq_variables.empty?
          #map << {uniq_variables.shift=>TheoryVariable.new(k)}
          map[uniq_variables.shift] = TheoryVariable.new(k)
          next
        end
        #t = m.shift
        var = TheoryVariable.new(k)
        #map += x.shift.collect {|u| {u=>var} }
        x.shift.each do |j|
          map[j] = var
        end
      end
      
      # Copy the the chain and update the mapping
      new_chains << Chain.new(uniq_chain.collect {|y| y.copy.map_to(map)})
      
    end
    return new_chains
    
  end
  
  # Returns an array of arrays containing matching ids
  #
  # matches e.g.  [[5,10],[11,17],[12,18],[1,6],[7,12],[13,5]]
  #
  def combine_matches(matches)
    
    results = []
    until matches.empty?
      start = matches.shift
      
      catch :no_change do
        loop do  
          initial_length = start.length
          #removed = temp2.delete_if {|x| (x | start).length != start.length+x.length }
          
          # TODO  A delete command to that returns what you were deleting would be nice
          index = matches.index {|x| (x | start).length != start.length+x.length }
          if index.nil?
            results << start
            throw :no_change
          end
          b = matches.slice!(index)
          start += b
          start.uniq!
        end
        
      end
    end    
    return results
  end    
  
  # Returns an array that matches one variable to another indicating that
  # they should be considered equal.
  #
  def matching_variables(arrangements,uniq_chain)
    #chains = []
    mappings = []
    arrangements.each do |arrangement|
      map = {}
      arrangement.each do |theory|
        
        dependents = uniq_chain.inject([]) {|total,x| total += x.dependents} 
        results = uniq_chain.inject([]) {|total,x| total += x.results}
        
        theory.each do |dependent_id,result_id|
          
          # Find the dependent with the matching id
          dependent = dependents.detect() {|x| x.theory_component_id == dependent_id}
          result = results.detect() {|x| x.theory_component_id == result_id}
          
          # Temporary check that everything is tickety boo
          if result.theory_variables.length != dependent.theory_variables.length
            raise StandardError.new('They should always have the same number of theory variables')
          end
          
          # Go through each of the variables and match up the values
          result.theory_variables.zip(dependent.theory_variables) do |x,y|
            
            if map.has_key?(x.theory_variable_id)
            end
            map[y.theory_variable_id] = x.theory_variable_id
          
          end            
          
        end
        
      end
      mappings << map
    end
    return mappings
  end    
  
  # Returns an array of all the ways the theory chain can be arranged
  # So dependent A -> result B 
  #
  # @param  chain       An array containing all the theories in order
  # 
  def chain_arrangements(chain)
    arrangements = []
    next_link_arrangement(arrangements,[],chain)
    return arrangements
  end
  
  def next_link_arrangement(arrangements,arrangement,chain)
    # Take out link and find the results that match its dependents
    link = chain.pop
    
    # Stop if the all the links in the chain have been met (the last one has nothing left to be dependent on)
    if chain.empty?
      arrangements << arrangement
      return
    end    
    
    # TODO  Down the line I should see if Cauldron can tidy this up
    
    # Saves what dependent connects to what result
    # e.g. connection = {16=>[26, 28], 17=>[26, 28]}
    connection = {}
    link.dependents.each do |dependent|

      # Get all the results from the rest of the chain
      results = chain.inject([]) {|total,x| total + x.results }
      
      # Go through the rest of the chain and find the results with the same structure
      connection[dependent.theory_component_id] = results.select do |x| 
        x.same_structure?(dependent)
      end.collect {|x| x.theory_component_id}
   
    end
    
    # TODO  I need to re-do allot of the connecton stuff - I was using theories with arround 650 dependents and
    #       it was generating an insane size of arrangements.  I think it is plausable to handle that size a theory
    #       but I should re-do this bit.  
    #
    #       I may need to reduce the theories to only include the dependent/result arrangements that change after
    #       the action is added.  
    
    # Calculate the total number of arrangements
    total_arrangements = connection.values.collect {|x| x.length}.inject(1) {|total,y| total *= y}
    
    # TODO  Need to include an escape here if there are too many total_arrangements
    
    # TODO  The theory_generator is generating too many results and dependents.
    
    # Find the various arrangements for the results
    # e.g. [[26,26],[26,28],[28,26],..]
    # NOTE I get a RangeError: too big to product     with larger theories
    connection_arrangements = connection.values.first.product(*connection.values[1..connection.values.length])
    
#    Alternative 
#    NOTE: I've rewritten this because the code above generates an error for larger theories
#    new_connection_arrangements = []
#    extend_arrangement(new_connection_arrangements,connection.values)
    
    # Jump back to the clearer dependent -> result arrangement
    # e.g. [{16=>26, 17=>26}, {16=>26, 17=>28}, {16=>28, 17=>26}, {16=>28, 17=>28}]
    nice_connection_arrangements = connection_arrangements.collect do |x|
      a = []
      connection.keys.zip(x) do |dependent_id,result_id|
        a << dependent_id
        a << result_id
      end
      Hash[*a]
    end

    # For each arrangement continue to the next link
    nice_connection_arrangements.each do |x|
      # TODO  Maybe use a hash with the theory id in instead
      a = arrangement.copy + [x]
      next_link_arrangement(arrangements,a,chain.copy)
    end      
    
  end
  
  def extend_arrangement(total,groups,group=[])
    if groups.empty?
      total << group
      return
    end
    groups.shift.each do |x|
      extend_arrangement(total,groups.copy,group.copy.push(x))
    end
  end
  
  # Returns all the implementation permutations for the theory.
  def implement_chain(chain,mapping=Mapping.new)
    
    
    # Implement the theory in all the permutations
    # NOTE: Need to get the mapping during the implementation
    link = chain.shift
    
    # TODO  Rewriting permutations takes quite long, I think it could be greatly reduced by 
    #       stricting the posibilities by reviewing the dependents.  For example: 
    #
    #         if(var6.kind_of?(Fixnum))
    #           return true
    #         end
    #
    # TODO  I shouldn't treat the realisable fixnum variables as fair game.  They should only
    #       TestCaseIndexFixnum and only available to things of that type. 
    #
    link_permutations = link.rewrite_permutations(@potential_values,mapping)
    implemented_chains = []
    link_permutations.each do |x|
      implement_next_link(implemented_chains,chain.copy,[link],[x])
    end
    
    return implemented_chains
    
  end    
  
  def implement_next_link(implemented_chains,chain,previous_chain,partial_implemented_chain)
    if chain.empty?
      implemented_chains << partial_implemented_chain
      return
    end
    next_link = chain.shift
    
    # Create an hash to show how the results-dependents are linked.
    # TODO  Because I am loading the theories from Marshal dumps I need to make sure they all have unique ids
    results_to_dependents = {}
    
    dependent_mapping = conversion_mapping(partial_implemented_chain,previous_chain,next_link)

    #    # Now implement the next theory using the mapping dependency already established.
    dependent_mapping.each do |mapping|
      
      # NOTE: The mapping is only restricted between the dependent and result connection
      implemented_links = next_link.rewrite_permutations(@potential_values,mapping)
      
      implemented_links.each do |x|
        extended_implemented_chain = partial_implemented_chain.copy << x
        previous_chain = previous_chain.copy << next_link
        implement_next_link(implemented_chains,chain,previous_chain,extended_implemented_chain)
      end    
    end
    
  end
  
  # Returns a mapping hash that will describe how to implement the next theory
  # so that it is compatiable with current chain.   
  #
  def conversion_mapping(implemented_chain,current_chain,next_theory)
    
    # Find all the permutations of theory dependents meet by the current chain.
    
    # For each dependent find all the current implementations that meet it
    # e.g. {16=>[26, 28, 12], 17=>[26, 28, 12]}
    # TODO  Should only include the most recent chain if the result contains a 
    #       last_runtime_method variable.
    results = current_chain.inject([]) {|total,x| total + x.results }
    arrangements = next_theory.dependents.inject({}) do |total,dependent|
      total[dependent.theory_component_id] = results.select do |x| 
        x.same_structure?(dependent)
      end.collect {|x| x.theory_component_id}
      total
    end
  
#    # ------------- Development Code -------------
#    arrangements.each do |key,value|
#      value.each do |x|
#      end
#    end
    
    # Get the various permutations of the dependent to result
    result_values = arrangements.values
#     http://www.ruby-doc.org/core/classes/Array.html#M000287    
#     TODO  Need to check when there is only one dependent    
#    [1,2].product()            #=> [[1],[2]]
#    [1,2].product([])          #=> []    
    
    variations = result_values.first.product(*result_values[1..result_values.length])
    # e.g. [[26, 26], [26, 28], [26, 12], [28, 26], [28, 28], [28, 12], [12, 26], [12, 28], [12, 12]]
    # TODO  Maybe an array with the dependent id in would be more useful
    #       e.g. [[16=>26,17=>26],[16=>26,17=>28],...
    
    # Need to find all the mappings that will still be consistent
    potential_mappings = []
    variations.each do |x|
      
      # Go through each dependent to result pair
      catch :incompatiable do 
        index = 0
        mapping = Mapping.new

        arrangements.each_key do |dependent_id|
          
          # ----------- Development ----------------
          
          # Find the implementation with this result
          theory_result = results.detect {|y| y.theory_component_id == x[index]}
          
          # Find the dependent that will be mapped
          theory_dependent = next_theory.dependents.detect {|y| y.theory_component_id == dependent_id}
          
          # Find the implementation that contains the selected result
          # TODO  This approach implies that the same theory can be used twice in the chain.
          # TODO  I could probably avoid allot of this by having implementation ids and including the 
          #       mapping with the implementation's results
          theory_implementation = implemented_chain.detect do |y| 
            y.results.any? {|z| z.theory_component_id == x[index]}
          end
          
          # Map the id of dependent to the real value used by the result
          theory_result.theory_variables.zip(theory_dependent.theory_variables) do |z,y|
            
            if mapping.has_key?(y.theory_variable_id)
              throw :incompatiable if mapping[y.theory_variable_id] != theory_implementation.mapping[z.theory_variable_id] 
            end
          
            mapping[y.theory_variable_id] = theory_implementation.mapping[z.theory_variable_id]
          end        
          index += 1
        end
        potential_mappings << mapping
      end        
    end
    
    return potential_mappings
    
  end
  
  def find_theories_with_these_results(theories,results)
     return theories.select do |theory|
       results.all? {|x| theory.has_result_structure?(x)}
     end
  end
 
  # Find the theories that match any of the results. 
  #
  def find_the_theories_with_these_results(theories,results)
  end
  
  # 
  def add_link(complete_chains,chain,theories)
    
    last_theory = chain.last
    
    
    # Find the theories that can meet last theories dependency
    # TODO  Should this be looking for just one theory?  If more than one theory is
    #       added they might not be compatible.
    results = find_theories_with_these_results(theories,last_theory.dependents)
    if results.empty?
      complete_chains << chain
      return
    end

    # Try to find any additional links to the new chain
    results.each do |x|
      extended_chain = chain.copy.push(x)
      add_link(complete_chains,extended_chain,theories)
    end
    
  end
  
  # Returns a number of updated mappings based on what if possible
  # for the first theory and the current mapping for the end.
  #  
  def refine_initial_mapping(theory,mapping,runtime_method,test_cases)

    # TEMP
    # 1.  What theory variables don't have real values?
    # 2.  What real values are available?
    # 3.  For each real variable identify the theory variables it could be.
    # 4.  Given the possibilities work out the permutations
    
    # Find the theory variable ids that don't have real values
    var_ids = theory.dependents.inject([]){|total,x| total << x.theory_variables.collect {|z| z.theory_variable_id}}.flatten.uniq
    unasigned_var_ids = var_ids-mapping.keys
    
    # Development
    
    # Find the available real values
    available_real_values = @potential_values-mapping.values
    
    # Determine the mermutations of unassigned var ids to available real values.
    # NOTE: I'm sure how efficient it is working out every permutation especially
    #       when a dependent link "varA.kind_of?(Fixnum)" could narrow the 
    #       combinations considerably.
    value_permutations = available_real_values.permutation(unasigned_var_ids.length).to_a
    var_value_permutations = value_permutations.inject([]) do |total,x|
      r = []
      x.zip(unasigned_var_ids) do |y,z|
        r << z
        r << y 
      end
      total << Mapping.new(Hash[*r])
    end
    
    # = Remove any mapping permutaions that don't work =
    passible_mappings = []
    var_value_permutations.each_with_index do |possible_mapping,i|
    
      # Combine the possible mapping with current actual mapping
      m = mapping.merge(possible_mapping)
      
      # Using this mapping go through each dependent and check it works
      # (if it doesn't work then it's a none starter)      
      # TODO  I don't really need to implement the full theory - just the dependents
      implementation = theory.map_to(m)
      
      # Use each implementation and find the ones that work
      next unless implementation.meets_dependencies?(runtime_method,test_cases)
      passible_mappings << m
      
      
    end
    return passible_mappings
      
  end    
  
end
