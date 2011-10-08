# This is just a wrapper for elements that should be wrapped in parenthesis.  
#
class Container
  
  def initialize(*tokens)
    @tokens = tokens
  end      

  def replace_theory_variables!(mapping)
    @tokens.each_with_index do |x,i|
      if x.kind_of?(TheoryVariable) && mapping.has_key?(x.theory_variable_id)
        @tokens[i] = mapping[x.theory_variable_id].copy
        next
      end
      @tokens[i].replace_theory_variables!(mapping) if @tokens[i].respond_to?(:replace_theory_variables!)
    end
  end     

  def subst_variable!(id,var)
    @tokens.each_with_index do |token,i|
      if token.kind_of?(Variable) && id == token.variable_id
        @tokens[i] = var
      end
      if token.kind_of?(Statement)
        token.subst_variable!(id,var)
      end
    end
    self
  end

  def write(tab=0)
    line = '('
    tab.times {line += "  " }
    @tokens.each do |code|
      line += code.write
      break if code.object_id == @tokens.last.object_id
    end
    return line+')'
  end
  
  def describe(tab=0)
    line = '('
    tab.times {line += "\t" }
    @tokens.each do |code|
      line += code.describe
      break if code.object_id == @tokens.last.object_id
    end
    return line+')'
  end  
  
  def copy
    return Container.new(*@tokens.collect {|x| x.copy} )
  end
  
  def select_all(results=[],&block)
    results.push self if block.call(self)
    @tokens.each do |x|
      if block.call(x)
        results.push(x)
      end
      if x.respond_to?(:select_all) 
        x.select_all(results,&block)  
      end
    end
    return results
  end    
  
  def has?(&block)
    return true if block.call(self)
    @tokens.each do |x|
      return true if block.call(x)
    end
    return false
  end      
  
  # This method writes the statement out as a literal string.  In the sense
  # that any of the variables used in the statement are converted to literals
  # and written.  Unknown variables are not written yet though.
  #
  # This method is called during tracking to give an indication what the statement
  # being tracked is doing.
  # 
  # TODO  I am treating unknown variables as a special case that is the same 
  #       value e.g. 'var' - but for determining equivalent processes it isn't
  #       ideal becuase you loose track of what variables is used in each 
  #       statement.  Although I'll wait unitl I can come up with an example
  #       and come up with a solution then.
  #
  def to_literal_string
    return @tokens.inject('') do |complete,part|
      complete += part.to_literal_string
    end
  end    
  
end