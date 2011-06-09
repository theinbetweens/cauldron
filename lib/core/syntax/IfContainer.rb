# TODO  I'm not sure whether to keep the IfContainer class or just drop it
#       and use Statement.new(If.new,Liter.new(9) etc..)
#       if I don't change it IfContainer should probably become a type of Statement

class IfContainer < Statement
  
  def initialize(*parameters)
    # TODO  It would be better to use super here
    #super(*parameters)
    # TODO  i think this is just passed a statement - so it only ever has one parameter - I prefer it that way
    #parameters.each { |x| self.push(x) }
    parameters.each do |code|
      self.push(code.copy)
    end
    
    # TODO  I might change the statement_id to be determined by the structure
    #       of the statement.
    @statement_id = @@statement_id
    @@statement_id += 1    
    
  end
  
  # Retunrs the contents of the if_container instance as string contained
  # within paraenthesis e.g. 
  # 
  # if(var_a == var_b)
  #
  def write(indent=0)
    line = If.new.write(indent)
    line += '('
    self.each do |x|
      line += x.write
      line += ' ' unless x.object_id == last.object_id
    end
    line += ')'
    return line
  end
  
  def describe(indent=0)
    line = If.new.write(indent)
    line += '('
    self.each do |x|
      line += x.describe
      line += ' ' unless x.object_id == last.object_id
    end
    line += ')'
    return line
  end  
  
  def replace_theory_variables!(mapping)
    self.each_with_index do |x,i|
      if x.kind_of?(TheoryVariable) && mapping.has_key?(x.theory_variable_id)
        self[i] = mapping[x.theory_variable_id].copy
        next
      end
      self[i].replace_theory_variables!(mapping)
    end
  end        
  
  # TODO  Doesn't need to be here(duplicated results)
  def select_all(results=[],&block)
    results.push self if block.call(self)
    self.each do |x|
      if block.call(x)
        results.push(x)
      else
      end
      if x.respond_to?(:select_all) 
        x.select_all(results,&block)  
      end
    end
    return results
  end
  
  # Returns a duplicate of this IfContainer instance
  #
  def copy 
    a = IfContainer.new(*self.collect {|x| x.copy})
    a.statement_id = @statement_id
    return a 
  end
  
  # TODO  Write tests for this
  # Returns a string containing the syntax for the container but where
  # all the values are literals e.g. 
  #
  # if(var_a == var_b) whould become "if(6 == 7)"
  #
  def to_literal_string
    line = If.new.write
    line += '('
    self.each do |x|
      line += x.to_literal_string
      line += ' ' unless x.object_id == last.object_id
    end
    line += ')'
    return line    
  end
  
end