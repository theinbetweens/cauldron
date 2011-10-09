# A nested statement is a special kind of statement group that contains 
# a opening statement.  For example the .each method of an array would
# be a nested statement.
#
#  Below is the parser intrepretaiton for var1.any? { |x| x.include? var2.id }
#
#   var1.any? do |x|
#     var2 = var1.chop
#   end
#     
#  s(:iter, 
#    s(:call, 
#      s(:call, nil, :var1, s(:arglist)), 
#      :any?, 
#      s(:arglist)
#    ), 
#    s(:lasgn, :x), 
#    s(:lasgn, 
#      :var2, 
#      s(:call, 
#        s(:call, nil, :var1, s(:arglist)), 
#        :chop, 
#        s(:arglist)
#      )
#    )
#  )
#     
#     =========================
#     
#     var1.any? { |x| x.include? var2.id }   
#     
#  s(:iter, 
#    s(:call, 
#      s(:call, nil, :var1, s(:arglist)), 
#      :any?, 
#      s(:arglist)
#    ), 
#    s(:lasgn, :x), 
#    s(:call, 
#      s(:lvar, :x), 
#      :include?, 
#      s(:arglist, 
#        s(:call, 
#          s(:call, nil, :var2, s(:arglist)), 
#          :id, 
#          s(:arglist)
#        )
#      )
#    )
#  )
# 
# TODO  I might just combine BlockStatement and StatementGroup since you
#       all groups of statements have a containing statement even if
#       that statement is a method.
# 
# e.g. ['garrus','wrex'].each do |x|
#         # internal_statements
#       end
#
# This is equivalent to :iter of the parser
#
class BlockStatement < OpenStatement    
  include ActsAsTrackable
  include ActsAsStatement  
    
  # TODO  I'm not sure whether I need to use a statement since a instance call will generally do.  Although
  #       I'll need to fix the tabbing in "write" if I stop it from using statements.
  #
  def initialize(statement,block_container=BlockContainer.new(BlockVariable.new),*internal_statements)
    super(statement,*internal_statements)
    #@statement = statement
    
    raise StandardError.new('Expecting block_container ') unless block_container.kind_of?(BlockContainer)
    @block_container = block_container
    
  end
  
  def write(tab=0)
    l = @statement.write(tab)+' '+Do.new.write+" "+@block_container.write+"\n"
    self.each do |x|
      l += x.write(tab+1)+"\n"
    end
    tab.times {l += "  " }    
    l += 'end'+"\n"
    return l
  end
  
  def write_with_uniq_id(tab=0)
    # Check the file type of tab
    raise StandardError.new('Unexpexted class "'+tab.class.to_s+'" for Fixnum (number of tabs)') unless tab.kind_of? Fixnum

    line = @statement.write_with_uniq_id(tab)+Do.new.write+" "+@block_container.write_with_uniq_id+"\n"
    self.each do |x|
      if x.respond_to?('write_with_uniq_id')
        line += x.write_with_uniq_id(tab+1)+"\n"
      else
        line += x.write(tab+1)+"\n"
      end      
    end
    tab.times {line += "\t" }    
    line += 'end'+"\n"
    return line

  end  
  
  # Writes out the nested statement with the appropriate tabbing but
  # also includes the value of variables within the output.  This 
  # method presumes that the nested statement has been realised.
  #
  def write_with_value(tab=0)
    l = @statement.write_with_value(tab)+" "+Do.new.write+" "+@block_container.write_with_value+"\n"     
    self.each do |x|
      l += x.write_with_value(tab+1)+"\n"
    end
    tab.times {l += "\t" }    
    l += 'end'+"\n"
    return l    
  end  
  
  def copy

    result = BlockStatement.new(@statement.copy,@block_container.copy,*self.collect {|x| x.copy})  
    # TODO  This means the scope id is being incremented for statements only exist for the declaration
    result.scope_id = scope_id
    result.scope = scope.copy
    result.statement_level = statement_level
    return result
  end
  
  # Creates a copy of the current nested statement but without any statements
  #
  def copy_base
    result = BlockStatement.new(@statement.copy,@block_container.copy)     
    # TODO  This means the scope id is being incremented for statements only exist for the declaration    
    result.scope_id = scope_id
    return result
  end
  
  # This is a quick check that really only applies to standard statements.  It checks 
  # that the statement doesn't just re-declare an existing variable e.g. 
  # var_a = var_b would be classed as simple. 
  #
  def is_simple?
    return false
  end
  
  # Returns all the variables used in the statement since the 
  # statement should never declare new variables.
  #
  def not_declared_variables
    return @statement.variables
  end
  
  # Returns the id of the block variable - although the terminolgy
  # of declared might imply a = sign essential it is declared here.
  # TODO  My approach implies only one block variable but there could
  #       be more than that.  I should allow multiple block variables.
  def declared_variable_id
    raise StandardError.new('Not allowing multiple block variables just yet') if @block_container.length > 1
    return @block_container.first.variable_id
  end
  
  # Returns an unpdated nested statement that has been fully realised.
  #
  # @param  method_map    A history object for the nested statement or method the
  #                       nested statement resides.
  #
  def realise2(method_map)
    
    # Start by realising the containing method
    opening_statement = @statement.realise2(method_map)
    
    # Now realise the block container
    block_container = @block_container.realise2(method_map)
    
    # Finally realise the internal statements
    copied_internal_statements = []
    self.each do |x|  
      copied_internal_statements.push(x.realise2(method_map))
    end
    
    # Now create a duplicate nested statement
    result = BlockStatement.new(opening_statement,block_container,*copied_internal_statements)
    result.scope_id = scope_id
    result.scope = scope.copy
    result.statement_level = statement_level
    return result
    
  end
  
  # TODO  This seems wrong there is no block or opening statement
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
    return false unless @block_container.realised?
    return false unless self.all? {|x| x.realised? } 
    return true
  end
  
  # Returns an array of all the unrealised variables in the nested statement
  #
  def unrealised_variables
    results = []  
    results += @statement.unrealised_variables
    results += @block_container.unrealised_variables
    self.each do |x|
      results += x.unrealised_variables
    end
    return results
  end
  
  # Returns each unrealised variable
  #
  def each_unrealised_variable
    unrealised_variables.each do |x|  
      yield x
    end
  end

  # Returns the number of statements represented by this nested statement.
  # 
  # NOTE  I have been counting the opening statement and closing statement
  #       as separate statements.  I'm not sure if this is the write 
  #       approach though.  I might have line_count and statement_count
  #
  def statement_count
    return self.inject(2) {|count,x| count += x.statement_count}    
  end
  
  # Returns the first copy of a variable it can find.
  # 
  # TODO  Really it should find the latest version of the variable
  #       working backwards like the RuntimeMethod call.  Although
  #       this might be a redundant concept since I don't think there
  #       can ever be more than one variable with the exact id.
  #
  def find_variable(id)
    failed_to_find = lambda{raise StandardError.new("Unable to find variable with id "+id.to_s) }
    return variables.detect(failed_to_find) {|x| x.variable_id == id}    
  end
  
  # Returns an array of all the variables contained within the nested 
  # statement.
  #
  def variables
    results = []  
    results += @statement.variables.collect {|x| x.copy} 
    results += @block_container.variables.collect {|x| x.copy}
    self.each {|x| results += x.variables}
    return results
  end
  
  def find_statement_that_declares_variable(id)
    @block_container.each do |x|
      if x.variable_id == id
        return self.copy
      end
    end
    self.each do |y|
      if y.kind_of?(Statement)
        if y.declared_variable_id == id then return y.copy end
        next
      end
      if y.kind_of?(BlockStatement)
        y.find_statement_that_declares_variable(variable_id)
      end
    end
    # TODO  I would rather a custom error
    raise StandardError.new('Failed to find statement that declared variable id '+id.to_s)
  end
  
  # TODO  This duplicates allot of the calls in the super.trackify method
  # Returns a new block statement that has been trackified.  A 
  # trackified block statement has a statement call after each 
  # line.
  # 
  # @param  tracking_method     A runtime tracking method instance 
  # @param  line                An array thats length represents the current line.
  #
  def trackify(tracking_method,line)
    
    # First copy the base nested statement and repopulate it
    result = copy_base
    
    # Start by trackifying the opening statement
    opening_variables = abstract_variables_for_tracking(@statement,@block_container)
    result.push(tracking_statement(tracking_method,line,@statement,opening_variables))
    
    # For each line in the nested statement include a tracking call
    # TODO  I don't think this would trackify further open statements
    self.each do |x|
      result.push(x.copy)
      
      # Now include a tracking call for after the statement
      line_variables = abstract_variables_for_tracking(x)
      # TODO  Check that the line is going up
      result.push tracking_statement(tracking_method,line,x,line_variables) 
    end

    return result
    
  end
  
  # Returns a duplicate of this nested statement up until the
  # the specified limt.
  # 
  # TODO  I need to use an array rather than a fixnum for the limit 
  #       since scope is lost otherwise.  This seems a bit of hack
  #       and I should revise.
  #
  def partial(limit)

    # Check that limit is greater 0 
    raise StandardError.new('At least one line is required to create nested statement') if limit == 0
    
    # Add the nested statement and reduce the limit
    result = copy_base    
    limit.pop    

    # Goes through each statement contained in the nested statement and adds it 
    # to the returned nested method until the limit has been reached or this
    # nested statement has exhausted its statements.
    index = 0
    while(limit.length >0 && index < self.length)
      x = self[index]
      if x.kind_of?(Statement)
        result.push(x.copy)    
        index += 1
        limit.pop
      elsif x.kind_of(BlockStatement)
        result.push(x.partial(limit))    
        index += 1
      end
    end
    return result
  end
    
end