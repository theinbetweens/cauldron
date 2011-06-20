require "logger"
class Chain
  # TODO  This access is proably temporary
  attr_reader :chain_mapping

  # 
  # @param  nodes     An array of theories in order
  # 
  def initialize()
    @values, @nodes = {}, [] 
    
    # Create an array of possible ids for any theories added
    @uniq_theory_instance_ids = ('A'...'Z').to_a 
    
    # Create a result version of 'finish'
    finish = Parser.run("if(runtime_method.all_pass?(test_cases))\nreturn true\nend")
    tail_theory = finish.write
    tail_theory.gsub!('runtime_method','var1')
    tail_theory.gsub!('test_cases','var2')
    tail_dependent = TheoryDependent.new(StringToTheory.run(tail_theory))
    # TODO  Drop @tail_theory as a instance variable
    @tail_theory = Theory.new([tail_dependent],nil,[])
    
    # NOTE: Now the head and tail are using the same ids for their variables
    @chain_mapping = ChainMapping.new()
    
    # Get the value mappings for the chain
    tc = Parser.run('test_cases')
    real_method = Parser.run('runtime_method')
    
    # Add the tail to the nodes list
    add_link(@tail_theory,{1=>real_method,2=>tc})
    
  end
  
  # TODO  I want to drop allot of these quick methods
  def <<(node)
    @nodes << node
  end
  
  def length
    return @nodes.length
  end
  
  def each(&block)
    @nodes.each(&block)
  end
  
  def [](index)
    return @nodes[index]
  end

  def first
    return @nodes.first
  end
  
  def last
    return @nodes.last
  end  
  
  def reverse
    return Chain.new(@nodes.reverse)
  end
  
  def shift
    return @nodes.shift
  end
  
  def copy
    #return Chain.new(@nodes.copy)
    return Marshal.load(Marshal.dump(self))
  end
  
  def empty?
    return @nodes.empty?
  end
  
  def pop
    return @nodes.pop
  end
  
  def collect(&block)
    return @nodes.collect(&block) 
  end
  
  def write(tab=0)
    return @nodes.inject('') {|total,x| total += x.write}
  end
  
  def describe(tab=0)
    return @nodes.inject('') {|total,x| total += x.describe}
  end
  
  # Returns an array of all the unique theory variables used within
  # the chain.
  #
  # e.g. [0,6,7] 
  # 
  def uniq_theory_variable_ids
    return @nodes.inject([]) do |total,theory| 
      total = total | theory.all_theory_variables.collect {|x| x.theory_variable_id}
    end
  end
  
  # Returns a new chain where they are all using the same respective theory
  # variables.
  #
  # TODO  This seems to create implemented theories - I'm not sure this is what I want
  #
  def unify_chain
    unless complete?
      raise StandardError.new('Only complete chains can be unified')
    end
    unified_theories = @nodes.inject([]) do |total,theory|
      mapping = generate_theory_mapping(theory.theory_instance_id)
      mapped_theory = theory.map_to(mapping)
      total.push(mapped_theory)
    end
    return UnifiedChain.new(unified_theories)
  end
  
  # DEVELOPMENT
  # Because I'm using Marshal to restore some of the theories I just need to check that 
  # none of the components have duplicate ids.
  #
  def duplicate_component_ids?
    collection = TheoryCollection.new(@nodes)
    component_ids = collection.components.inject([]) {|total,x| total << x.theory_component_id }
    return (component_ids.length != component_ids.uniq.length)
  end
  
  # Returns the number of breaks in the chain - this is essential the number of
  # unmet depements.
  #
  def broken_link_count
    collection = TheoryCollection.new(@nodes)
    return collection.dependents.inject(0) do |total,dependent| 
      unless @chain_mapping.connected_component_ids.include?(dependent.theory_component_id)
        total += 1
      end
      total
    end      
  end
  
  # TODO  Really need a method to highlight what is connected to what
  
  # Writes out the chain but highlights any of links in the chain weren't connected 
  # to a dependent.
  # 
  def highlight_broken_links
    if duplicate_component_ids?
      StandardLogger.instance.warning('You are using theories that share the same component_id')
    end
    unmet = []
    each_unmet(:dependents,0,@nodes) do |index,theory,dependent|
      unmet << dependent.theory_component_id  
    end
    return @nodes.inject('') {|msg,x| msg += x.highlight(unmet)}
  end
  
  # Attempts to add a new link to form a complete chain between the head and tail.  It starts
  # by linking to the tail and then head.
  #
  # TODO  link_permutations mighht be a more appropriate name - this name is inapproriate for the 
  # =>    the return type.
  #
  def add_link(theory,value_mapping=nil)
    
    # Give the theory an instance id
    theory = theory.copy
    raise StandardError.new('Reached limit to chains length') if @uniq_theory_instance_ids.empty?
    theory.theory_instance_id = @uniq_theory_instance_ids.shift
    
    # Save the values for use later during the global mapping 
    @values[theory.theory_instance_id] = value_mapping
    
    # The first link added should be the tail
    if @nodes.empty?
      add_tail(theory,value_mapping)
      return
    end
    
    # The second link should be the head  
    # (this doesn't necessarily need to be be case but I'll keep this convention
    if @nodes.length == 1 
      return add_link_to(theory,0,value_mapping)
    end
    
    # Attempt to add a link to all the possible locations (head and tail are exempt)
    extended_chains = []
    (1...@nodes.length).each do |position|
      res = self.copy.add_link_to(theory,position,value_mapping)
      extended_chains += res
    end
    return extended_chains
    
  end
  
  # Returns true if the chain can be connected from the head to the tail.
  # 
  def complete?
    
    # Check that all the variables in all the theories have been globally mapped, as well as the head
    @nodes.each do |theory|
      # Find the global variable for each of the theory variables
      theory.all_theory_variables.each do |theory_variable|
        begin
          to_global_id(@chain_mapping,theory.theory_instance_id,theory_variable.theory_variable_id)
        rescue StandardError => e   
          StandardLogger.instance.error(e)       
          return false
        end
      end
    end
    return dependents_met?
    
  end
  
  # This uses the supplied theories and checks whether the dependents
  # of any of theories that might be used are reachable. 
  #
  # NOTE: This is only a rough assessment of whether the dependents are available
  #       it doesn't mean that it is solvable but does identify that it definitely
  #       isn't.
  #
  def solvable?(finish,theories)
    
    # Get the finish and check all the dependents can be met by the theories
    all_results = theories.inject([]) {|total,x| total += x.results}
    return false unless all_results.any? {|x| x.same_structure?(finish)}
    
    # Find the theories that can solve the problem and check their dependents can be met
    # TODO  Should probably include the head theory in here too.
    collection = TheoryCollection.new(theories.copy)
    finishing_theories = []
    collection.each_with_result_structure(finish) do |t,r|
      finishing_theories.push(t) 
    end
    
    finishing_theories.each do |x|
    end
    res = finishing_theories.any? do |x|
      dependency_tree_met?(x,theories+[self.first.copy])
    end
    return res
  end  
  
  # Implements a new the chain where all the theories are implemented.  It can 
  # only be implemented if the chain is complete e.g. all the dependents and results
  # are matched up.
  #
  def implement
    raise StandardError.new('This chain is not complete') unless complete?

    # Generate a global value mapping - so global id to real value
    unifyied_chain = unify_chain

    return unifyied_chain.implement(intrinsic_mapping)
    
  end  
  
  #  Returns an array of implemented theories that have variable syntax that can
  #  be mapped to literal syntax(runtime_method,0,...) and also contain
  #  real values for each of the variables.  So the runtime method will 
  #  include all statements added to it. 
  #
  def each_theory_progression(initial_runtime_method,test_cases)
    raise StandardError.new('Only complete theories can be watched') unless self.implementable?
    
    theories = []
    previous_runtime_method = initial_runtime_method.copy
    chain_validator = TheoryChainValidator.new
    progressive_chain do |chain,theory|
      initial_runtime_method.copy
      runtime_method = chain_validator.build_method_from_chain( chain.implement,
                                                                initial_runtime_method.copy,
                                                                test_cases)
      
      # Create the intrinsic mapping for the theory
      unified_chain = chain.unify_chain
      
      # * Go through each variable and find the intrinsic value
      theory_intrinsic_mapping = Mapping.new
      values = {:before=>{},:after=>{}}
      unified_chain.theory_variables.each do |var|
        intrinsic_value = global_id_intrinsic_value(var.theory_variable_id)
        theory_intrinsic_mapping[var.theory_variable_id] = intrinsic_value        
        
        # Add the actual varlue of the intrinsic value
        if intrinsic_value.kind_of?(IntrinsicRuntimeMethod)
          values[:before][var.theory_variable_id] = previous_runtime_method.copy
          values[:after][var.theory_variable_id] = previous_runtime_method.copy
          next
        end
        if intrinsic_value.kind_of?(IntrinsicTestCases)
          values[:before][var.theory_variable_id] = test_cases.copy
          values[:after][var.theory_variable_id] = test_cases.copy
          next
        else
          values[:before][var.theory_variable_id] = intrinsic_value.literal
          values[:after][var.theory_variable_id] = intrinsic_value.literal
        end
      end

      # Generate a unified version of the theory
      mapping = generate_theory_mapping(theory.theory_instance_id)
      unified_theory = theory.map_to(mapping)
            
      yield theory.map_to(theory_intrinsic_mapping,values), unified_theory
      
      # Save the previous method for the dependents
      previous_runtime_method = runtime_method
      
    end
    return theories
    
  end  
  
  # Return true if the chain can be implemented - so all the theories have literal values
  # associated with them.  This could be directly via when the theory was added to the 
  # chain or indirectly via connecting two theories.
  #
  def implementable?
    self.implement
    return true
  rescue StandardError => e
    StandardLogger.instance.info e 
    return false
  end
  
  # Returns an array of all the theory variables used in the chain
  #
  def theory_variables
    return TheoryCollection.new(@nodes).theory_variables
  end
  
  # TODO  Maybe just move this method to the UnfiedChain class
  # Returns a set containing the intrinsic statements that created the variables.  It should look
  # something like the following.
  #
  # [{:global_variable_id=>0,:intrinsic_statement=>runtime_method,:written_statement=>'var1'},
  #  {:global_variable_id=>3,:intrinsic_statement=>runtime_method.params[0],:written_statement=>'var1.params[var3]'},
  #  ...]
  #
  # Currently the only way variables are created are for array access.
  # 
  # There should not be the case where there are duplicate intrinsic_statements but different global_variable_ids - 
  # for now at least.
  # 
  def variables_creation(runtime_method,test_cases)
    raise StandardError.new('This should only be called on complete chains') unless complete?
    res = []
    unify_chain.theory_variables.each do |var|
      
      puts '--------variable creation for '+var.write
      
      intrinsic_value = global_id_intrinsic_value(var.theory_variable_id)
      if intrinsic_value.kind_of?(IntrinsicRuntimeMethod)
        res << {
          :global_variable_id=>var.theory_variable_id,
          :intrinsic_statement=>Parser.run('runtime_method'),
          :written_statement=>'var'+var.theory_variable_id.to_s,
          :variable_value=>runtime_method.copy
        }    
      elsif intrinsic_value.kind_of?(IntrinsicTestCases)
        res << {
          :global_variable_id=>var.theory_variable_id,
          :intrinsic_statement=>Parser.run('test_cases'),
          :written_statement=>'var'+var.theory_variable_id.to_s,
          :variable_value=>test_cases.copy
        }        
      else
        
        puts 'Not intrinsic---------->?'
        # TODO  This whole bit is just really rushed------------------ write tests! 

        # Find all the statements that include that variable 
        unified_components = unify_chain.components
        
        # TODO  This is an extremely clumsy approach
        # Collect all the written components matching the delcaration
        written_components = unified_components.collect {|x| x.write}
        written_components = written_components.select {|x| x.include?('var'+var.theory_variable_id.to_s)}
        
        puts 'written_components.length: '+written_components.length.to_s
        # => DEV
        temp_component = written_components.first
        puts 'temp_component: '+temp_component
        # => MATCH var0.params[var2] in runtime_method.add_statement_at(OpenStatement.new(TheoryStatement.new(If.new, Container.new(var0.params[var2], Equivalent.new, var1[var4][:params][var3]))),var0.statement_id)
        reg = eval('/[\w\d\.\[\]:]*\['+var.write+'\]/')
        
        puts temp_component.match(reg)
        
        # TODO  Should use the Parser to find the statement with the varx in
        #var_match = /\s.*\[var[\d]\]/
        #var_match = /^[\s|\(]+(.*\[var[\d]\])/
        var_match = reg
        usage_statements = written_components.inject([]) do |total,x|
          
          #unless x.write.match(/\s.*\[var[\d]\]/).nil?
          unless x.write.match(var_match).nil?
            match = x.write.match(var_match)[0]
            total << TheoryStatement.new(StringToTheory.run(match))
          end
          total
        end
        intrinsic_statements = usage_statements.collect {|x| x.map_to(intrinsic_mapping)}
        
        unless intrinsic_statements.collect {|x| x.write}.uniq.length == 1
          raise StandardError.new('Unable to create intrinsic variable create for variable '+var.theory_variable_id.to_s)
        end
        
        res << {
          :global_variable_id=>var.theory_variable_id,
          :intrinsic_statement=>intrinsic_statements.first,
          :written_statement=>usage_statements.first.write,
          :variable_value=>intrinsic_mapping[var.theory_variable_id].copy
        }
        
      end       
    end
    return res
  end
  
protected  
  
  # Returns the intrinsic mapping for the unified chain
  #
  def intrinsic_mapping
    
    # Generate a global value mapping - so global id to real value
    unifyied_chain = unify_chain
    
    # Get all the global variable ids -
    m = Mapping.new
    unifyied_chain.theory_variables.each do |x|
      m[x.theory_variable_id] = global_id_intrinsic_value(x.theory_variable_id)
    end
    return m
  end
  
  # Returns an array of all the components used in the chain 
  # TODO  Could be turned into a set.
  def components
    return @nodes.inject([]) {|total,x| total += x.components }
  end
  
  # Returns the intrinsic value for specified global id.  The intrinsic value is
  # IntrinsicRuntimeMethod.new(7), IntrinsicFixnum.new(8), ...
  #
  # @param  global_id   The global id saved in chain_mapping
  #
  def global_id_intrinsic_value(global_id)
    
    # Possible values for global_id
    potentential_values = []
    @chain_mapping.mapping[global_id].each do |key,value|
      if @values[key]
        potentential_values << @values[key][value]
      end
    end
    
    if potentential_values.empty?
      raise StandardError.new('Could not find an implementation value for global variable '+global_id.to_s)
    end
    
    if potentential_values.length > 1 
      unless potentential_values.collect {|y| y.write}.uniq.length == 1
        pp potentential_values
        raise StandardError.new('There is more than one possible value for this('+global_id.to_s+') - it is ok if there the same')
      end
    end
    return potentential_values[0]    
    
  end
  
  # Replaces the current chain with the values specified
  #
  def create!(n,m,instance_ids,v=[])
    @nodes, @chain_mapping, @uniq_theory_instance_ids, @values = n,m,instance_ids,v
    # TODO  I need to check there won't be a problem with @uniq_theory_instance_ids
    return self
  end
  
  def nodes=(obj)
    @nodes = obj
  end
  
  # Returns any number of new chains after adding this link to the position
  # specified.
  # 
  # TODO  SHould I raise an error if it doesn't connect to anything?
  #
  def add_link_to(theory,position,value_mapping)
    # TODO  Down and up are quite similar I should consider refactoring
    
    # Do through each of the dependents and then find a result with the same structure
    mappings = [@chain_mapping.copy]
    upward_links = @nodes[0...position]

    theory.copy.dependents.each do |dependent|
      each_result(position,upward_links) do |index,link,result|
        if result.same_structure?(dependent)
          new_mappings = []
          mappings.each do |x|
            new_mappings << x.apply_mapping_update(theory,dependent.theory_component_id,link,result.theory_component_id)
          end
          mappings = new_mappings
        end
      end
    end
    
    # Go down the rest of the chain looking for exisitng links with unmet dependents
    downward_links = @nodes[position...@nodes.length]
    theory.copy.results.each do |result|
      each_unmet(:dependents,position,downward_links) do |index,link,dependent|
        if dependent.same_structure?(result)
          new_mappings = []
          mappings.each do |x|
            new_mappings << x.apply_mapping_update(link,dependent.theory_component_id,theory,result.theory_component_id)
          end
          mappings = new_mappings
        end
      end
    end
    
    # Strip out any mappings that are identical to original they are 
    # links that haven't been connected with anything 
    # (don't include the head since it only has one thing to connect to)
    # => TODO Do I like this? It means I'm including some forced connections
    unless @nodes.length < 2
      
      # Identify the mappings that are the same
      mappings = mappings.select {|x| !@chain_mapping.same?(x) }
      # => TODO Should inlcude error/warning and exit when there are no new mappings
    end
    
    # Identify any orphan variables in the action and give them uniq global ids
    mappings.each do |mapping|
      theory.orphan_action_variables.each do |x|
        mapping.add_mapping(
          mapping.next_free_global_id,
          theory.theory_instance_id,
          x.theory_variable_id
        )
      end
    end
    
    #puts '-----------------------------------------CREATING MAPPING -------'
    #pp mappings
        
    # Create a new nodes array with the new theory in place
    updated_nodes = @nodes.copy
    updated_nodes.insert(position,theory)
    
    # Create a new chain for each of the possible mappings
    extended_chains = []
    mappings.each do |x|
      c = self.copy
      new_chain = c.create!(updated_nodes,x,@uniq_theory_instance_ids.copy,@values.copy)
      extended_chains << new_chain 
    end
    return extended_chains
  end  
  
  # TODO  This could probably be replaced by the normal add_link_to method
  def add_tail(theory,value_mapping={})
    @nodes.push(theory.copy)
  end
  
  # Returns the global id of the variable given the theory id and the variable
  # id.
  # 
  def to_global_id(global_mapping,theory_id,theory_variable_id)
    global_id = global_mapping.find_global(theory_id,theory_variable_id)
    if global_id.nil? 
      raise StandardError.new('Unable to find global id for theory '+theory_id.to_s+' theory_variable_id: '+theory_variable_id.to_s)
    end
    return global_id
  end
  
  # NOTE: The :tail isn't a real link, the last link just matches the :tail settings 
  def link_to_tail(theory)
    
    # * Find the dependent(s) that connect to the finish
    linking_results = theory.select_result_structure(@tail)
    raise StandardError.new('Only expecting the theory to have one result that matches the finish') unless linking_results.length == 1
    if linking_results.empty?
      StandardLogger.instance.warning "this theory does not link to the tail"
      return
    end
    linking_result = linking_results.first
  end
  
#  def front_of_chain
#    return [@nodes.first.copy]
#  end
  
  # Returns a new theory mapping that replace the theories local ids with global 
  # ids.
  #
  def generate_theory_mapping(theory_id)
    mapping = Mapping.new
    @chain_mapping.mapping.each do |key,value|
      if value[theory_id]
        mapping[value[theory_id]] = TheoryVariable.new(key)
      end
    end
    return mapping
  end
  
  # Returns true if the dependents of all the theories have been me.  It 
  # does this by starting from the last link in the chain(the one cloest to
  # the tail) and goes through each of it's dependents.  It searches up the 
  # the chain until it finds a result that matches. 
  #
  # Check that all the dependents have been connected to a result component
  #
  # NOTE: This should only be ran on unfied chains.
  # 
  def dependents_met?
    collection = TheoryCollection.new(@nodes)
    return collection.dependents.all? do |dependent| 
      @chain_mapping.connected_component_ids.include?(dependent.theory_component_id)
    end
  end
  
  # Start from the back of the chain and work backwards to the head.
  #
  def dependent_met?(dependent,chain)
    chain.reverse.each do |theory|
      theory.results.each do |result|
        return true if result.write == dependent.write
      end
    end
    return false
  end
  
  # Returns an array of all the depdendents in the chain that haven't
  # been met by the front of the chain.
  #
  def unmet_dependents
    results = []
    return results if self.empty?
    duplicate_chain = self.copy
    last_link = duplicate_chain.pop
    last_link.dependents.each do |dependent|
      results.push dependent unless dependent_met?(dependent,duplicate_chain.copy)
    end
    return results+duplicate_chain.unmet_dependents
  end

  # Goes up through each theory in the chain from the position
  # specifies and yeilds any unment depndents or results and the
  # theory it belongs to.
  #
  # @param    approach    Either :depndents or :results 
  #
  def each_unmet(approach,position,nodes)
    # TODO  Need to exclude theories that use the immediate runtime method
    index = 0
    comp_ids = @chain_mapping.connected_component_ids
    nodes.each do |theory|
      unmets = theory.send(approach).select do |x|
        !comp_ids.include?(x.theory_component_id)
      end
      unmets.each {|x| yield index, theory, x}
      index += 1
    end
  end
  
  def each_result(position,nodes)
    index = 0
    nodes.each do |theory|
      theory.results.each {|x| yield index, theory, x}
      index += 1
    end    
  end
  
  # Returns a hash of all the unmet dependents down the chain (excluding the head)
  # and the link/theory that it belongs to.
  #
  def unmet_dependents_and_link
    results = []
    return results if self.empty?
    duplicate_chain = self.copy
    
    # Remove the head link from the chain
    duplicate_chain.shift
    
    duplicate_chain.length.times do
      last_link = duplicate_chain.pop
      last_link.dependents.each do |d|
        next if dependent_met?(d,duplicate_chain.copy)
        results.push({:dependent=>d.copy,:theory=>last_link.copy}) 
      end      
    end
    return results    
  end
  
  # Removes any results from the head that aren't needed to meet 
  # the dependents of the supplied theories.
  # 
  # NOTE  This method is only really needed while the head is so large
  #       as development continue I don't think this call will be needed.(26/04/2011)
  #
  def remove_superfluous_head_results!(theories)
    theory_dependents = theories.inject([]) {|total,x| total += x.dependents}
    new_results = []
    @nodes.first.results.each do |r|
      if theory_dependents.any? {|x| r.same_structure?(x)}
        new_results.push(r)
      end
    end    
    @nodes.first.results = new_results
  end  
  
  # Retruns true if all the dependents,and subsequent dependents of 
  # the theory can be met otherwise it returns false. 
  #
  def dependency_tree_met?(theory,theories,pending_theories=[])
    
    return theory.dependents.all? {|d| dependent_can_be_met?(d,theories,pending_theories+[theory.copy])}
    
    # Finish if the theory is already in pending theories or has no dependents.
  end
  
  def dependent_can_be_met?(dependent,theories,pending_theories=[])
    
    # Try to find theories thats result meets this dependent
    theory_collection = TheoryCollection.new(theories.copy)
    theory_collection.each_with_result_structure(dependent) do |theory,result|
      
      # Check whether the matching theory is in pending theories 
      # (it is already being checked otherwise)
      if pending_theories.any? {|x| x.theory_id == theory.theory_id}
        return true
      end
      
      #return dependency_tree_met?(theory,theories,pending_theories+[theory.copy])
      return dependency_tree_met?(theory,theories,pending_theories+[theory.copy])
      
    end
    StandardLogger.instance.warning '* failed to find a theory with a result to dependent: '
    StandardLogger.instance.warning dependent.describe
    return false
  end
  
private
  
  # Itterates through a progressive extending chain also returning
  # the theory that has just been added to the chain.
  #
  def progressive_chain
    return @nodes.length.times do |i|
      copied_chain = self.copy
      copied_chain.nodes = @nodes[0..i] 
      yield copied_chain, @nodes[i].copy 
    end
  end
  
end