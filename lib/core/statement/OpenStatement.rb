# This class represents the structure where a statement is declared 
# but doesn't close on the same line.  Instead it can contain any 
# number of other statements. 
# 
# for example 
# 
# if var_a == 'test'.select_all {|x| x.kind_of?(TheoryVariable)}
#   # do something
# end
#
class OpenStatement < StatementGroup
  include ActsAsTrackable  
  include ActsAsCode
  
  
  def initialize(open_statement,*statements)
    super(*statements)
    @statement = open_statement
  end
  
  def write(tab=0)
    line = @statement.write(tab)+"\n"
    line += super(tab+1)
    tab.times {line += "\t" }
    line += "end"
    return line
  end
  
  def describe(tab=0)
    line = @statement.describe(tab)+"\n"
    line += super(tab+1)
    tab.times {line += "\t" }
    line += "end\n"
    return line
  end  
  
  # Creates a copy of the current nested statement but without any statements
  #
  def copy_base
    result = self.class.new(@statement.copy)     
    # TODO  This means the scope id is being incremented for statements only exist for the declaration    
    result.scope_id = scope_id
    return result
  end  
  
  # Returns all the variables used in the opening statement as well as any 
  # child statements.   
  #
  # TODO  Write tests for this
  def variables
    return self.select_all([]){|x| x.kind_of?(Variable)}
  end

  def tokens
    return self.select_all([]){|x| x.kind_of?(Token)}
  end
  
  # Overrides the default array select_all method to include 
  # the opening statement and contents of the open statement.
  #
  def select_all(results=[],&block)
    @statement.select_all(results,&block)
    return super(results,&block)
  end
  
  # Create a duplicate of this OpenStatement instance
  # 
  # TODO  Write tests for this 
  # 
  def copy
    puts @statement.class.to_s
    result = self.class.new(@statement.copy,*self.collect {|x| x.copy })
    result.scope_id = scope_id
    result.scope = scope
    result.statement_level = statement_level    
    return result
  end
  
  # Returns a new open statement that has been trackified.  A 
  # trackified open statement has a statement call after each 
  # line.
  # 
  # @param  tracking_method     A runtime tracking method instance 
  # @param  line                An array thats length represents the current line.
  #
  def trackify(tracking_method,line)
    
    # First copy the base open statement and repopulate it
    result = copy_base
    
    # Start by trackifying the opening statement
    opening_variables = abstract_variables_for_tracking(@statement)
    track_statement = tracking_statement(
      tracking_method,
        line,
        statement_id.to_literal,
        opening_variables,
        @statement
    )
    result.push(track_statement)
    
    # For each line in the open statement include a tracking call
    # TODO  I don't think this would trackify further open statements
    self.each do |x|
      result.push(x.copy)
      
      # Now include a tracking call for after the statement
      line_variables = abstract_variables_for_tracking(x)
      # TODO  Check that the line is going up
      result.push tracking_statement(
                    tracking_method,
                    line,
                    x.statement_id,
                    line_variables,
                    x
      ) 
    end

    return result
    
  end  
  
  def replace_theory_variables!(mapping)
    @statement.replace_theory_variables!(mapping)
    self.each_with_index do |x,i|
      if x.kind_of?(TheoryVariable) && mapping.has_key?(x.theory_variable_id)
        self[i] = mapping[x.theory_variable_id].copy
        next
      end
      self[i].respond_to?(:replace_theory_variables!)
      self[i].replace_theory_variables!(mapping) if self[i].respond_to?(:replace_theory_variables!)
    end    
  end
  
  # Returns the statement_id of the embeded statement. 
  #
  # TODO  The nested statement should maybe have an idea 
  #       of its own.  It should probably have two ids
  #       to indicate at what point additional statements
  #       added e.g. inside/outside statement.
  #
  def statement_id
    return @statement.statement_id
  end
  
  # TODO  This seems wrong there is no opening statement
  def to_literal_string
    a = ''
    self.each do |x|
      a += x.to_literal_string
    end
    return a    
  end  
  
  # Returns true if the opening statement and all internal statements
  # have been realised.
  # 
  def realised?
    return false unless @statement.realised?
    return false unless self.all? {|x| x.realised? } 
    return true
  end
  
  def has?(&block)
    self.each do |x|
      return true if block.call(x)
    end
    return true if block.call(@statement)
    return false
  end
  
end