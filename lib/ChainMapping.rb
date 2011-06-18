# note about the global mapping=>
#
# This method needs to map the theory variables used in one theory to the 
# rest.  This basically means there is a global theory that has a respective
# id in each of the other theories in the chain. e.g.
#
# +----------+--------+--------+--------+--------+
# |Global #ID| head   | link#2 | link#3 | link#4 |
# +----------+--------+--------+--------+--------+
# |    0     |   1    |   1    |   2    |   89   |
# +----------+--------+--------+--------+--------+
# |    1     |   2    |   4    |   6    |   1    |
# +----------+--------+--------+--------+--------+

class ChainMapping
  attr_reader :mapping, :history
  
  def initialize(mapping={},history=[])
    @history, @mapping = history, mapping
  end
  
  def copy
    return ChainMapping.new(@mapping.copy,@history.copy)
  end
  
  # Returns the global id for the this theory variable in this theory.
  #
  # @param  theory_id     The id of the theory that is being retreived
  # @param  variable_id   The id of the theory variable in the context of the single theory
  #
  def find_global(theory_instance_id,variable_id)
    res = @mapping.detect do |key,value|
      value.has_key?(theory_instance_id) && value[theory_instance_id] == variable_id
    end
    return nil if res.nil?
    return res[0]
  end
  
  def same?(chain_map)
    return false if @mapping.length != chain_map.mapping.length
    return false if @history.length != chain_map.history.length
    
    puts '--------------------SAME--------------------'
    pp @history
    pp chain_map.history
    return @history == chain_map.history
  end
  
  # Adds a new variable mapping to a global id
  # TODO  Assigning global_id should probably not be allowed publically
  #
  def add_mapping(global_id,theory_instance_id,variable_id)
    if @mapping[global_id].nil?
      @mapping[global_id] = {}
    end
    # TODO  Write tests to check that the error is raised
    unless @mapping[global_id][theory_instance_id].nil?
      if @mapping[global_id][theory_instance_id] != variable_id
        raise ChainMappingError.new('This global variable has already been defined')
      end
    end
    # TODO  Should check that the theory_id#variable_id has not already been assigned to a global id
    @mapping[global_id][theory_instance_id] = variable_id
  end
  
  # TODO  I'd like to change global ids to letters for clarity
  # Returns the next key that hasn't been defined in the mapping
  def next_free_global_id
    a = (0..100).to_a.detect() {|x| !@mapping.has_key?(x)}
    raise StandardError.new('No more free global id') if a.nil?
    return a
  end
  
  # Returns a string listing all the dependent to result connections 
  # that have been made.
  #
  def display_history
    @history.each do |x|
    end
  end
  
  # TODO  This is temporary - it doesn't resolve the issue of the same theory
  #       being used twice.
  # Returns all the components that have been sucessfully connected to another
  # component.
  #
  def connected_component_ids
    @history.inject([]) {|total,x| total += x}
  end
  
  # Either returns an updated chain mapping if the mapping works or returns the 
  # existing mapping.
  #
  def apply_mapping_update(theory_a,component_a_id,theory_b,component_b_id)
    updated_mapping = copy
    begin 
      updated_mapping.connect(theory_a,component_a_id,theory_b,component_b_id)
    rescue ChainMappingError => e
      StandardLogger.instance.warning e
      return self.copy
    end
    return updated_mapping
  end
  
  # TODO  I need to include a mapping that doesn't declare a globlal_id.  A global id only needs 
  #       identified when connecting separate theories.

  # TODO  Mapping is not about theory_component_id it is about what is connected to what and
  #       when - consider when the same theory is added twice but connected differently.
  
  # TODO  This needs wrapped in some transaction incase one of the mappings won't work
  #       or in the wider context some of the other connections won't work.
  
  # Updates the global mapping to connect the two theories so that
  # they share the same global mapping
  #
  # TODO  Need to include the theories instance id  
  #
  def connect(theory_a,component_a_id,theory_b,component_b_id)
     
     #  Retrieve each of the components
     component_a = theory_a.find_component(component_a_id)
     component_b = theory_b.find_component(component_b_id)
     
     #  Check that the number of variables match
     unless component_a.theory_variables.length == component_b.theory_variables.length
       raise ChainMappingError.new('These components do not have the same number of variables') 
     end
     
     #  Go through each variable and confirm they have the same global mapping
     component_a.theory_variables.zip(component_b.theory_variables) do |variable_a,variable_b|
     
        # Do any of the theory variables already have a global id
        global_var_a = find_global(theory_a.theory_instance_id,variable_a.theory_variable_id)
        global_var_b = find_global(theory_b.theory_instance_id,variable_b.theory_variable_id)

        # Nearly variables has been added as global - add new global connections
        if ([global_var_a,global_var_b].all? {|x| x.nil?})
          mapping_global_id = next_free_global_id
          add_mapping(mapping_global_id,theory_a.theory_instance_id,variable_a.theory_variable_id)
          add_mapping(mapping_global_id,theory_b.theory_instance_id,variable_b.theory_variable_id)          
        else
        
          # If both the global ids are defined then they should be the same value.
          if([global_var_a,global_var_b].all? {|x| !x.nil? })
            if global_var_a != global_var_b 
              raise ChainMappingError.new(
                'Both global ids have already been defiend but are not equal '+global_var_a.to_s+' and '+global_var_b.to_s
              )
            end
            next
          end
        
          # Get the id of the only defined global id
          global_id = [global_var_a,global_var_b].detect {|x| !x.nil? } 
          
          # Add the mapping for both 
          add_mapping(global_id,theory_a.theory_instance_id,variable_a.theory_variable_id)
          add_mapping(global_id,theory_b.theory_instance_id,variable_b.theory_variable_id)
        end
      
    end
    
     @history.unshift([theory_a.theory_instance_id,component_a_id,theory_b.theory_instance_id,component_b_id])
     
  end
  
end

class ChainMappingError < StandardError
  
  def initialize(msg)
    super(msg)
  end
  
end