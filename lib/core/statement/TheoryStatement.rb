# This class represents the general descriptions used inside the three
# components of theories.  
#
# TODO  The statement class this extends is extremely bloated but I 
#       need to create some complex journeys before I can start to 
#       trim the fat. 
#
class TheoryStatement < Statement
  
  def initialize(*parameters)
    super(*parameters)
  end
  
  # TODO  map_to might replace the need for this method
  # TODO  How does this work for instance call containers and array access?
  def replace_theory_variables!(mapping)
    self.each_with_index do |x,i|
      if x.kind_of?(TheoryVariable) && mapping.has_key?(x.theory_variable_id)
        self[i] = mapping[x.theory_variable_id].copy
        next
      end
      self[i].replace_theory_variables!(mapping) if self[i].respond_to?(:replace_theory_variables!)
    end
  end
  
  # TODO  This method was just nicked from TheoryDependent 
  # TODO  A similar method exists in Statement
  # 
  def map_to(mapping)
    
    # Duplicate the current statement before it is rewritten
    rewritten_statement = self.copy
    
    # Find all the containers that contain TheoryVariables
    # NOTE  The statement is put in an array because select all doesn't include the array itself
    containers = [rewritten_statement].select_all {|x| x.respond_to?(:has?)}
    theory_variable_containers = containers.select {|x| x.has? {|y| y.kind_of?(TheoryVariable)}}
    
    # Rewrite the statement replacing the values
    theory_variable_containers.each do |z|
      z.replace_theory_variables!(mapping)
    end     
    
    return rewritten_statement
    #return TheoryDependent.new(rewritten_statement,@theory_component_id)
  end  
  
  # => 
  # => map [<TheoryVariable>=><TheoryVariable>]
  def replace_variables_alt!(map)
    self.each do |x|
      x.replace_variables_alt!(map)
    end
  end
  
  # TODO  Maybe use a opject to handle the output of the statement.
  def describe(tab=0)
    line = ''
    tab.times {line += "\t" }
    self.each do |code|
      line += code.describe
      break if code.object_id == self.last.object_id
    end
    return line
  end  
  
end