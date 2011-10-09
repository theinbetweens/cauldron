# The theory action represents the what theory inserts into the 
# main runtime method.
#
class TheoryAction
  include TheoryComponent
  
  attr_reader :target_id, :action
  # 
  # @param  action          A statement to insert into the main runtime method.
  #                         e.g. action.write => "return var8"
  # @param  target_id       The id of the nested statement or method to add the generated statement to.
  # 
  def initialize(action,target_id,theory_component_id=nil)
    raise StandardError.new('Expecting theory statement but was '+action.class.to_s) unless action.kind_of?(TheoryStatement)
    @action = action
    @target_id = target_id
    @theory_component_id = theory_component_id unless theory_component_id.nil?    
    generate_theory_component_id
  end
   
  # Provide a general description of the action, explaining the statement
  # it will add to the runtime method and where.  This is pseudo code
  # and shouldn't be interpretted at runtime.  Use "write" for runtime
  # actions.
  #
  # @param  tab     
  #    
  def describe(tab=0)
    # TODO  That is nicer way to do tabs - I should make the other methods consistent with it
    return ("  "*tab)+"<runtime_method>.add_statement_at(#{@action.describe},#{@target_id.describe})"
  end
  
  def write(tab=0)
    return ('  '*tab)+"<runtime_method>.add_statement_at(#{@action.write},#{@target_id.write})"
  end
  
  # Returns all the theory vairables in this theory action 
  #
  def theory_variables
    return @action.select_all {|x| x.kind_of?(TheoryVariable)}
  end
  
  # Returns a action implementation with the theory variable declarations replaced with
  # the values in the mapping hash. 
  # 
  def map_to(mapping)

    # Duplicate the current statement before it is rewritten
    rewritten_statement = @action.copy
    target_id = @target_id.copy
    
    # Find all containers of VariableDeclarations that declare a TheoryVariable
    containers = [rewritten_statement,target_id].select_all {|x| x.respond_to?(:has?)}
    theory_variable_containers = containers.select {|x| x.has? {|y| y.kind_of?(TheoryVariable)}}
    
    # Do any of the containers contain each other?
    # => TODO Need to prevent this
    all_theory_variables = Set.new
    theory_variable_containers.each do |x|
      results = x.select_all([]) {|y| y.kind_of?(TheoryVariable)}
      all_theory_variables += results
    end
    
    map = {}
    all_theory_variables.each do |x|
      next if mapping[x.theory_variable_id].nil?
      map[x] = mapping[x.theory_variable_id]  
    end
        
    rewritten_statement.replace_variables_alt!(map) 
    target_id.replace_variables_alt!(map)
    
    return ActionImplementation.new(rewritten_statement,target_id,@theory_component_id)
    
  end  
  
  def copy
    return TheoryAction.new(@action.copy,@target_id,@theory_component_id)
  end
  
  def statements_with_variable(variable_id)
    
    # Duplicate the current statement before it is rewritten
    rewritten_statement = @action.copy
    target_id = @target_id.copy
    
    # Find all containers of VariableDeclarations that declare a TheoryVariable
    containers = [rewritten_statement,target_id].select_all {|x| x.respond_to?(:has?)}
    theory_variable_containers = containers.select {|x| x.has? {|y| y.kind_of?(TheoryVariable)}}
    
    results = theory_variable_containers.select do |x|
      reg = eval '/var'+variable_id.to_s+'/'
      x.write.match(reg)
    end
    return results
    
  end
  
  
end