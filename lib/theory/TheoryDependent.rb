# A theory dependent is the "if" part of a theory.  It states what needs to be
# true for a theory to be valid.  For example "if varA == 7", would be 
# a theory dependent.
# 
class TheoryDependent
  include TheoryComponent
  
  attr_reader :statement
  # 
  # @param  statement         A theory statement 
  #                           e.g. StringToTheory.run("if(var1.pass?(var2))\nreturn true\nend")
  #
  def initialize(statement,theory_component_id=nil)
    raise StandardError.new('Expecting open statement but was '+statement.class.to_s) unless statement.kind_of?(OpenStatement)
    @statement = statement
    @theory_component_id = theory_component_id unless theory_component_id.nil?
    generate_theory_component_id
  end
  
  # Returns an abstract description of the dependent
  def describe(tab=0)
    return @statement.describe(tab)
  end
  
  def write(tab=0)
    return @statement.write(tab)
  end
  
  # Returns a deep copy of the theory dependent but with a unique object_ids, all the
  # data should be identical.
  #
  def copy
    return TheoryDependent.new(@statement.copy,@theory_component_id)
  end
  
  # Returns all the theory vairables in this theory
  # dependent. 
  #
  def theory_variables
    return @statement.select_all {|x| x.kind_of?(TheoryVariable)}
  end
  
  # TODO  The same code is used for both TheoryDependent and TheoryResult
  # Returns true if supplied statement has the same structure as this theory 
  # dependent's, it has the same structure if everything about the statement is
  # the same except for the variables.  This means that the map_to method
  # could be used to make it write identically.
  #
  def same_structure?(structure)
      return false unless structure.tokens.length == @statement.tokens.length
      return false unless structure.write_structure == @statement.write_structure
      return true
  end  
  
  # Returns a new theory dependent with the theory variables replaced with
  # the values in the mapping hash. 
  # 
  def map_to(mapping)

    # Duplicate the current statement before it is rewritten
    rewritten_statement = @statement.copy

    # Find all the containers that contain TheoryVariables
    # NOTE  The statement is put in an array because select all doesn't include the array itself
    containers = [rewritten_statement].select_all {|x| x.respond_to?(:has?)}
    theory_variable_containers = containers.select {|x| x.has? {|y| y.kind_of?(TheoryVariable)}}
    
    # Rewrite the statement replacing the values
    theory_variable_containers.each do |z|
      z.replace_theory_variables!(mapping)
    end     
    
    return TheoryDependent.new(rewritten_statement,@theory_component_id)
  end
  
  # Returns a duplicate theory dependent but with the theory 
  # variables replaced with those supplied. 
  #
  def rewrite_with(replacement_variables)
    raise StandardError.new("This theory dependent has #{theory_variables.length} not #{replacement_variables.length}") if replacement_variables.length != theory_variables.length
    rewritten_statement = @statement.copy

    # TODO  I think as well as copy I should have a rewrite_where(['var1'=>replacement_variables[0])
    
    # Find all the containers that contain TheoryVariables
    containers = [rewritten_statement].select_all {|x| x.respond_to?(:has?)}
    theory_variable_containers = containers.select {|x| x.has? {|y| y.kind_of?(TheoryVariable)}}

    # Collect all uniq variables
    # TODO  Check that only uniq variables are caught
    uniq_variables = theory_variable_containers.inject([]) {|results,x| results + x.variables }
    
    # Check that all the variables in the theory dependent can be replaced
    unless replacement_variables.length == uniq_variables.length 
      raise StandardError.new('Mismatch in the number of variables to be replaced and the number supplied')
    end
    
    # Create a mapping from the existing variable to the replacement ones
    # TODo  I really should use the varible id or something as the key
    mapping = []
    replacement_variables.zip(uniq_variables) do |x,y|
      mapping.push({:before=>y,:after=>x})
    end
    theory_variable_containers.each do |z|
      replacements = mapping.select {|x| x[:before].theory_variable_id == z.subject.theory_variable_id}
      z.subject = replacements.first[:after]
    end   
    return rewritten_statement 

  end
  
  # Returns an array of theory statements that realise this dependency
  # using the passed variables.
  #
  # http://en.wikipedia.org/wiki/Combination
  # http://chriscontinanza.com/2010/10/29/Array.html  
  # 5! FACTORIAL
  #
  def rewrite_permutations(realisable_variables)
    # TODO  Need to include a combination size check here - incase it is going to get insane
    raise StandardError.new('Currently requires at least one theory variable') if theory_variables.length == 0
    
    # Create an array of all the possible permutations that could replace this depenents' theory variables
    arrangements = realisable_variables.permutation(theory_variables.length).to_a

    # Construct a new theory dependent that use realisable variables inplace of 
    # the theory variables
    realisable_theory_dependents = []
    arrangements.each do |x|
        realisable_theory_dependents.push(self.copy.rewrite_with(x))
    end
    return realisable_theory_dependents
  end
    
end