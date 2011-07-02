module TheoryComponent
  include ActsAsCode
  
  attr_reader :theory_component_id
  
  # TODO  Complete hack for issue where component ids aren't unique - using marshal load
  @@theory_component_id = 0
  
  def generate_theory_component_id
    if @theory_component_id.nil?
      @theory_component_id = @@theory_component_id
      @@theory_component_id += 1
    end
  end
  
  # Returns all the theory vairables in this theory
  # dependent. 
  #
  def theory_variables
    return @statement.select_all {|x| x.kind_of?(TheoryVariable)}
  end    
  
  def tokens
    return @statement.tokens
  end
  
  def statements_with_variable(variable_id)
    
    # Duplicate the current statement before it is rewritten
    rewritten_statement = @statement.copy
    
    # Find all containers of VariableDeclarations that declare a TheoryVariable
    containers = [rewritten_statement].select_all {|x| x.respond_to?(:has?)}
    theory_variable_containers = containers.select {|x| x.has? {|y| y.kind_of?(TheoryVariable)}}
    
    results = theory_variable_containers.select do |x|
      reg = eval '/var'+variable_id.to_s+'/'
      x.write.match(reg)
    end
    return results
    
  end  
  
  # Returns an array of any of the accessors in the statement.  An accessor
  # is the chain to access a property e.g. in the following statement =>
  #
  # var1[:params][var3].something(var6)
  #
  # it would return ["var1[:params][var3]","var6"]
  #
  # The needed when trying to determine intrinsic values.  So in this case 
  # var1 couln't be a runtime_method instance becuase it doesn't use 
  # the has key
  #
  def accessors
    
  end
  
end