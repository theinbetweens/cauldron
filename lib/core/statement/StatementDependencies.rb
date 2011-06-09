#
# TODO  I might just make this part of StatementGroup
# 
# TODO TSort examples show a single use.  So you basically add all your variables 
# and then sort them once.  Rather than what I'm doing which is to attempt
# to find the dependencies for particular statements.  It might be better
# to rebuild the dependies each time and then do a single sort.

# Include a scope dependencies as well - if a statement resides within a nested statement
# the nested statement must come first.
#
#    New statement: - statement level: 183
#      var_5918 = var_652  +  var_658 
# 
#    Pre-requiste statements: 
#    var_34 = method_13 
#    var_34.times do |var_658|
#    end
#    var_652 = var_34  +  var_34 

# In this case the scope means that the nested "var_34.times do |var_658|" is dependent
# on var_652 = var_34  +  var_34.
#    
#    # Find the statement that contains this statement - if it exists
#    self.each do |x|
#      if x.kind_of?(BlockStatement)
#        if x.scope_id == statement.statement_level
#          
#          # Apply the dependencies for the statement to the containing statement
#          # unless it's the containing statement itself.
#          
#        end        
#      end
#    end
#
class StatementDependencies < Array
  #include TSort   # See p750
  
  alias :array_push :push  
  
  def initialize(*params)
    super()
    #@dependencies = {}
    
    # Add the statements
    params.each {|x| self.push(x)}
  end

  # TODO  Write about this in more detail
  #
  def tsort_for_statement(statement)
    
    @statement_sort = TopologicalStatements.new    
    add_dependent_statements(@statement_sort,statement)    
    
    # TODO  Should probably copy the @statement_sort before itterating through it
    #
    each_used_nest_statement(@statement_sort,statement) do |x| 
      # CONTINUE - Why are these nested statements populated
      
      # Find statements that have the same scope as this
      each_nested_statement(@statement_sort,statement,x.scope_id) do |y|
         
         #  Add the inner statement dependencies onto the nested statement
         @statement_sort[x.statement_id] += @statement_sort[y.statement_id]
      end
      
    end
        
    return @statement_sort.tsort
    
  end
  
  def dependencies_for(statement_id)

    # Check that the statement exists
    unknown_statement_id = lambda {raise StandardError.new('Could\'nt find statement_id '+statement_id.to_s)}
    self.detect(unknown_statement_id) {|x| x.statement_id == statement_id}
    
    # 
    @statement_sort = TopologicalStatements.new
    
    # First find the initial statement
    initial_statement = find_statement(statement_id)
    add_dependent_statements(@statement_sort,initial_statement)
    
    
    return @statement_sort.tsort
  end
  
  def add_dependent_statements(tsort,statement)
    dependencies = find_dependencies_for(statement)
    tsort[statement.statement_id] = dependencies
    
    # Find the dependiencies for the 
    dependencies.each do |x|
      add_dependent_statements(tsort,find_statement(x))
    end
  end
  
  def find_statement(id)
    self.each do |x|
      if x.statement_id == id
        return x
      end
    end 
    # TODO  Should raise error here
  end
  
  # Returns an array of statement ids of all the statements that the supplied 
  # statement is dependent on.
  #
  # @param  statement   A statement instance thats dependencies are returned
  #
  def find_dependencies_for(statement)
    results = []
    statement.not_declared_variables.each do |x| 

      # Find the original declaration statement
      # TODO  Doesn't catch no results
      statement_ids = self.inject([]) do |ids,y| 
        #ids.push(y.statement_id) if x.uniq_id == y.created_variable.uniq_id
        if x.uniq_id == y.created_variable.uniq_id
          # TODO  Quick hack to prevent bug
          ids.push(y.statement_id) unless statement.statement_id == y.statement_id
        end
        ids
      end
      
      # Find any further required uniq ids
      x.uniq_id_history.each do |y|             
        # TODO  Change to detect since this presumes a result is found
        statement_ids.push(self.select {|z| z.created_variable.uniq_id == y}.first.statement_id)
      end
      raise StandardError.new('Can\'t find the declaration of '+x.write+' or '+x.write_with_uniq_id) if statement_ids.empty?      
      results += statement_ids               
      results.each do |y|
        raise StandardError.new('dksafkjdashfkahsdf '+statement.statement_id.to_s) if(y==statement.statement_id)
      end
#      # TODO  Change to catch :found
#      found = false
#      self.each do |y|
#        #if x.variable_id == y.declared_variable_id
#        if x.uniq_id == y.created_variable.uniq_id
#          found = true
#          results.push(y.statement_id)
#          break
#        end
#      end
#      raise StandardError.new('Can\'t find the declaration of '+x.write+' or '+x.write_with_uniq_id) unless found         
    end
    return results
  end
  
  # Saves any of the statements thats dependencies are being
  # saved.
  #
  # @param  statement      
  #
  def push(statement)
            
    # Check that any statements this statement is dependent on is included
    find_dependencies_for(statement)

    # Add the new piece of code to the statement
    array_push(statement)   
    
  end
  
  # Returns the saved statement based on the statement id provided
  #
  # @param  statement_id    The statement id of the stored statement.
  #
  def find_statement(statement_id,new_statement=nil)
    unless new_statement.nil?
      return new_statement if new_statement.statement_id == statement_id
    end
    return self.detect {|x| x.statement_id == statement_id}
  end
  
  # Returns a string to be printed out for the general use of 
  # debugging.
  #
  # @param  topsort         Topological sort containing the dependencies 
  #                         for each statement.
  # @param  statements      An array of statements that have already been
  #                         saved.
  # @param  new_statement   The new statement that has yet to be included 
  #                         in a large method and hasn't been realised yet.
  #
  def display_statement_dependencies(topsort,statements,new_statement)
    msg = ''  
    msg += topsort.inspect+"\n"
    topsort.each_key do |x|
      msg += x.to_s+"\n"
      msg += find_statement(x,new_statement).write+"\n"
    end
    return msg
  end
  
  # Modifies the supplied topological sort to include scope dependency.  This
  # basically involves applying the dependencies of nested statements to 
  # the containing statement. e.g. 
  # 
  # var_a = 6
  # 5.times do |var_b|
  #   var_c = var_b+var_a
  # end
  #
  # So "var_c = var_b+var_a" is dependent on the two proceeding statements but
  # sequentially they could be written as 
  # 
  # 5.times do |var_b| 
  # var_a = 6
  # var_c = var_b+var_a
  #
  # But when put it into its particular nest we end up with
  # 
  # 5.times do |var_b|
  #   var_c = var_b+var_a
  # end
  # var_a = 6
  # 
  # @param  topsort         Topoligical sort indicating an ordering dependencey
  # @param  new_statement   The new statement that is yet to saved internally
  #                         (because it hasn't been realised)
  #
  def apply_scope_dependencies(topsort,new_statement)
    
    # Find each nest statement and then any statements contained within
    each_used_nested_statement(topsort,new_statement) do |x|
#      CONTIUE
    end
            
  end
  
  # Yeilds each nested statement.  Despite the naming convention a nested
  # statement is really a nest statement.  NOTE This is not every contained
  # NestStatement but rather those used.
  #
  # TODO  NestStatement would be a more reflective name - after all the statements
  #       within the statement are nested.
  #
  def each_used_nest_statement(topsort,new_statement)
    topsort.each_key do |x|
      found_statement = find_statement(x,new_statement)
      yield found_statement if found_statement.kind_of?(BlockStatement)
    end
  end
  
  # Yeilds each statement that is nested within the scope specified
  # 
  # @param  topsort       The has containing each relevent statement id as well
  #                       as there dependencies.
  # @param  statement     The statement in the process of being added.  It needs
  #                       passed since is not yet saved within this class.
  # @param  scope_id      The scope id of the nest statement that contains the 
  #                       nested statements.
  #
  def each_nested_statement(topsort,new_statement,scope_id)
    topsort.each_key do |x|  
      found_statement = find_statement(x,new_statement)
      # TODO  I need to clarify the terms ,scope,scope_id and statement_level
      #       - I think one can at least go or at least have less confusing names.
      if found_statement.statement_level == scope_id
        yield found_statement
      end
    end
  end
    
end