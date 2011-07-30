class Theory
  attr_reader :dependents, :action, :results, :theory_id, :example_runtime_method
  
  # TODO  This is only temporaily accessible for debug
  attr_writer :results
  
  attr_accessor :theory_instance_id
    
  @@theory_id = nil
  #
  # @param  example_runtime_method      A runtime method instance with this theories action applied to it and
  #                                     which meets the theories dependents with a certain set of test cases.
  #
  def initialize(dependents,action,results,example_runtime_method=nil)
    @dependents, @action, @results, @example_runtime_method = dependents, action, results, example_runtime_method
    #@theory_id = @@theory_id
    #@@theory_id += 1
    @theory_id = Theory.next_theory_id
  end
  
  def copy
    #return Theory.new(@dependents.copy,@action.copy,@results.copy)
    return Marshal.load(Marshal.dump(self))
  end
  
  def self.next_theory_id
    if @@theory_id.nil?
      FileUtils.mkdir(theories_directory) unless File.exists?(theories_directory)
      highest_integer = 0
      Dir.glob(File.join(theories_directory,'*')).each do |filename|
        if filename.match(/(\d+)/)
          highest_integer = $1.to_i if $1.to_i > highest_integer     
        end
      end      
      @@theory_id = highest_integer
    end
    @@theory_id += 1
    return @@theory_id
  end
  
  def self.theories_directory
    # the home directory code is duplicated
    realHome = ["HOME", "HOMEPATH"].detect {|h| ENV[h] != nil}
    if not realHome
      StandardLogger.instance.warning "Couldn't detect a home directory"
    end
    # => TODO Should use proper version
    return File.join(ENV[realHome],'cauldron','0-1-1','theories')    
  end    
  
  def irrelevant?
    dependents.empty? and results.empty? and action.nil?
  end
  
  # Identify the dependents and actions that haven't changed between adding the action.
  # 
  def identify_unchanged

    # Identify the dependents that change after the action is added
    changing_dependents = []
    @dependents.each do |dependent|
      next if @results.any? {|x| x.write == dependent.write}
      changing_dependents << dependent 
    end        
    
    # Identify the results that don't occur in the dependents
    changing_results = []
    @results.each do |result|
      # TODO Should this use the changing_dependents
      next if @dependents.any? {|x| x.write == result.write}
      changing_results << result
    end
    
    # TODO  Stripping out the dependents will mean that they won't be 
    #       met and the theory might be dismissed unfairly.  e.g. it
    #       needs var1.kind_of?(RuntimeMethod).  It should probably start
    #       with the minimum and work backwards - e.g. adding the dependents
    #       until it doesn't fail.
    
    # Create a new runtime method with the irrelevant changes removed    
    return Theory.new(changing_dependents,action.copy,changing_results,example_runtime_method.copy)
  end
  
  #  Loads a particular theory that has been saved to a file
  #
  def self.load_theory(theory_id)
    directory_path = $LOC+File.join('test','fixtures','theories',theory_id.to_s)
    raise StandardError.new("Theory fixture #{theory_id} does not exist") unless(File.exists?(directory_path))
    dump_file = File.open(File.join(directory_path,'dump'),'r')
    return Marshal.load(dump_file)    
  end
  
  # Returns a new theory where all the theory variables ids start from
  # the supplied value.
  #
  def uniq_theory_variables(min_id)
      
    ids = all_theory_variables.inject([]) {|total,x| total << x.theory_variable_id}

    # Pair the olds with the new ones
    map = ids.inject(Mapping.new) {|total,x| total[x] = TheoryVariable.new(min_id); min_id += 1; total}
    
    # Duplicate the current theory and sustute the theory variables
    # TODO  Maybe shouldn't be a TheoryImplementation at this point
    return self.map_to(map)
    
  end
  
  # Returns the component with the id supplied
  #
  def find_component(component_id)
    return (dependents+results).find {|x| x.theory_component_id == component_id}
  end
  
  # Returns true if the theory contains a result that's structure is similar 
  # to that of the supplied result implementation.
  # 
  # @param  structure     The theory result implementation that's structure is compared
  #                       with this theorie's results. 
  #
  def has_result_structure?(structure)
    return @results.any? {|x| x.same_structure?(structure)}
  end
  
  # Returns the results thats structure matches that provided. 
  #
  def select_result_structure(structure)
    return @results.select {|x| x.same_structure?(structure)}  
  end
  
  # Returns an array of any variables that only exist in the action.  These
  # are important for determining global ids, the results and dependents global
  # id is determined my what they are connected to, these action variables aren't
  # connected to anything.
  #
  def orphan_action_variables
    return [] if @action.nil?
    excluded_variables = (@dependents+@results).inject([]) {|total,x| total += x.theory_variables }
    orphans = @action.theory_variables - excluded_variables
    # TODO  Should probably raise an error for this situation.
    # TODO  Actually as long as I include context when the value is added and the value it should
    #       be fine e.g. var2[:params][var3] for var3
    StandardLogger.instance.warning "You really should not have variables that are not in dependents - there is no context for the value"
    return orphans
  end
  
  # @param  mapping   { 1=>[],
  #                     2=>#<IntrinsicTestCases:0xb712d13c>,
  #                     3=>#<IntrinsicRuntimeMethod:0xb712c980>
  #                   }
  # @param  values    {
  #                     1=>0,
  #                     2=><#TestCases>
  #                     3=><#Runtime Method>
  #                   }
  #
  def map_to(mapping,values={})
    raise StandardError.new('Please use the maping datatype') unless mapping.kind_of?(Mapping)
    # return TheoryImplementation.new(
        # @dependents.collect {|y| y.map_to(mapping)},
        # @action ? @action.map_to(mapping) : nil,
        # @results.collect {|y| y.map_to(mapping)},
        # mapping,
        # values
      # )    
    return TheoryImplementation.new(
        @dependents.collect {|y| y.map_to(mapping)},
        @action ? @action.map_to(mapping) : nil,
        @results.collect {|y| y.map_to(mapping)},
        mapping,
        values
      )       
  end
  
  # TODO  Need to write tests for this that use the mapping
  def rewrite_permutations(realisable_variables,partial_mapping=Mapping.new())
    
    # Get an array of all the theory variables 
    a = all_theory_variables
    
    # Strip out the theory variables that have already been accounted for
    free_theory_variables = a.select {|x| !partial_mapping.has_key?(x.theory_variable_id) }
    
    # If all the mapping has been determines just return the single permutation
    return [self.map_to(partial_mapping)] if free_theory_variables.length == 0
    # TODO  This doesn't currentlt remove the initial finish values
    arrangements = (realisable_variables - partial_mapping.values).permutation(free_theory_variables.length).to_a   
    
    # Map the arrangements to specific theory variables ids.
    remaining_mapping = arrangements.inject([]) do |total,x|
      # TODO  I can probably get the 0 value to be the correct value
      hash_table = Mapping.new(Hash[*free_theory_variables.collect { |v| [v.theory_variable_id,0] }.flatten])
      free_theory_variables.zip(x) do |y,z|
        hash_table[y.theory_variable_id] = z
      end
      total << hash_table
    end    
    return remaining_mapping.inject([]) do |total,x|
      total << self.map_to(x.merge(partial_mapping))
    end
    
    raise StandardError.new('Need to complete the rest of the mapping with the available realisable variables')
    
  end
  
  # Returns the highest theory variable id used by the theory
  def highest_theory_variable_id
    return all_theory_variables.sort {|y,z| y.theory_variable_id <=> z.theory_variable_id }.reverse.first.theory_variable_id
  end
  
  # Returns an array of all the theory variables used within the theory.
  # 
  def all_theory_variables
    
    # Get all the theory variables used in the @action, dependents and results 
    a = ([@action]+@dependents+@results).select{|x| x != nil}.inject([]) {|total,x| total += x.theory_variables }
    
    # Filter out only the uniq theory vairables
    # http://stackoverflow.com/questions/109781/uniq-by-object-attribute-in-ruby
    return a.inject({}) {|total,x| total[x.theory_variable_id]=x; total}.values
    
  end    
  
  # Returns an abstract description of theory with colour matching
  # for common variables.
  #
  # TODO  Include example here
  #
  def describe
    
    # TODO include - theory_instance_id
    # Describe the despendencies
    description = 'if: '+"\n"
    @dependents.inject(description) {|description, x| description += x.describe(1) }
    
    # Describe the action
    unless @action.nil?
      description += "\n"+"action: \n"
      description += @action.describe(1)
    end
    
    # Describe the result
    description += "\n"+"result: \n"
    @results.inject(description) {|description, x| description += x.describe(1) }
    return description
      
  end
  
  def write
    
    # Describe the despendencies
    description = 'if: '+"\n"
    @dependents.inject(description) {|description, x| description += x.write(1)+"\n" }
    
    # Describe the action
    unless @action.nil?
      description += "\n"+"action: \n"
      description += @action.write(1)
    end
    
    # Describe the result
    description += "\n"+"result: \n"
    @results.inject(description) {|description, x| description += x.write(1)+"\n" }
    return description    
  end
  
  def highlight(component_ids=[])
    # @log.error("\033[0;31m\ "+msg+"\033[00m\ ")
    # Describe the despendencies
    description = 'if: '+"\n"
    @dependents.inject(description) do |description, x|
      if component_ids.include?(x.theory_component_id)
        description += "\033[0;31m\ "+x.write(1)+"\033[00m\ "+"\n"
      else
        description += x.write(1)+"\n"
      end
    end
    
    # Describe the action
    unless @action.nil?
      description += "\n"+"action: \n"
      description += @action.write(1)
    end
    
    # Describe the result
    description += "\n"+"result: \n"
    @results.inject(description) {|description, x| description += x.write(1)+"\n" }
    return description     
  end
  
  # Returns an array of all the theory components used in the theory.
  # 
  def components
    return ([@action]+@dependents+@results).select{|x| x != nil}
  end

end