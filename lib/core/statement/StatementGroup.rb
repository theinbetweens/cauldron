class StatementGroup < Array
  attr_reader :scope, :scope_id, :statement_level
  attr_writer :scope, :scope_id, :statement_level
  
  # The scope id is used to determine what variables are available with the nested statement
  @@scope_id = 0    
  
  alias :array_push :push    
  
  def initialize(*statements)
    super()
    statements.each {|x| self.push(x)}
    
    # Update the scope id for the nested statement
    @scope_id = @@scope_id
    @@scope_id += 1
    
    @scope = [@scope_id]
    
  end
  
  def cauldron_method_calls
    return ['.statement_id']
  end    
  
  def write(tab=0)
    line = ''
    self.each {|x| line += x.write(tab)+"\n" }
    return line
  end    
  
  def describe(tab=0)
    line = ''
    #self.each {|x| line += x.describe(tab)+"\n" }
    self.each do |x| 
      line += x.describe(tab)+"\n"
    end
    return line
  end    
  
  # Removes any statements that simple re-declare an existing statement
  # e.g var_a = var_b.
  #
  def remove_simple
    results = StatementGroup.new
    self.each do |x|
      results.push x unless x.is_simple?
    end
    return results
  end
  
  def push(*entries)
    self.entries.each do |x|
      x.scope = [@scope_id]
    end
    #super.array_push(*entries)
    entries.each do |y|
      
      # TODO  Oddly super.array_push seems to add it twice - might investigate
      #super.array_push(y)
      array_push(y)
    end
  end
  
  # TODO  This method name doesn't suit what it returns
  def statement_id
    return @scope_id
  end
  
  # Returns a statement container (either a runtime method or a nested statement)
  # thats scope is the statement level specified.  This means that any statements
  # with the statement level specified should reside directly in the statement
  # container.
  #
  # @param  statement_level   The statement level the statement group should 
  #                           contain statements at.
  #
  def find_container_at_level(statement_level)
    return self if scope_id == statement_level
    self.each do |x|
      if x.kind_of?(StatementGroup)
        begin
          return x.find_container_at_level(statement_level)
        rescue FailedToFindStatementContainerError => e
          next
        end
        #result = x.find_container_at_level(statement_level)
        #return result unless result.nil?
      end
    end
    raise FailedToFindStatementContainerError.new('Failed to find containing statement with id '+statement_level.to_s)
    #return nil
    #raise StandardEror.new('There is no container at level '+)
  end
  
  # Returns the statement thats id matches that supplied.
  #
  # @param  id    The id of the statement should exist in the runtime method
  #
  def find_statement(id)
    self.each do |x|    
      begin 
        return x.find_statement(id)
      rescue FailedToFindStatementError => e
        next
      end
    end
    raise FailedToFindStatementError.new('Couldn\'t find statement with id '+id.to_s)
  end  
  
  # Returns an array of all the runtime method instances that are
  # required for this statement group.  This is essentially the 
  # runtime methods referenced in DefCalls.
  #
  def find_all_required_runtime_methods
    results = []
    self.each do |x|
      results += x.find_all_required_runtime_methods
    end
    return results
  end
  
  def copy 
    result = self.class.new(*self.collect {|x| x.copy })
    result.scope_id = scope_id
    result.scope = scope
    result.statement_level = statement_level
    return result
  end
  
  # Identify any of the contained statements that override an 
  # existing variable. 
  # 
  # @param  already_declared      An array of previously declared variable ids in the 
  #                               following format. [{:variable_id=>43},{:variable_id=>12}, ..]
  #
  def identify_overriding_statements(already_declared=[])
    self.each do |x|
      x.identify_overriding_statements(already_declared)
    end
  end  
  
  # Returns an array of overriding statements that reside inside
  # this statement group.  A overriding statement is a statement that 
  # re-declares or modifies a previously declared variable.
  #
  # @param  overriding_statements   An array of statements that have been overriden
  #                                 within the statement group.
  #
  def find_overriding_statements(overriding_statements=[])
    self.each do |x|
      x.find_overriding_statements(overriding_statements)
    end
    return overriding_statements
  end  
  
end