class RealisedRuntimeMethod < StatementGroup
  include ActsAsRuntimeMethod
  
  attr_reader :method_id
  attr_writer :method_id
    
  def initialize(x,*statements)
    @open = true      
    @parameters = x
    super(*statements)
  end
  
  def push(statement)
    raise StandardError.new('This realised method has been closed') unless @open
    super(statement)
  end
  
  def close
    @open = false
  end
  
  def cauldron_method_calls
    return ['.params']
  end    
  
  def write
    return MethodWriter.new.write(
      @parameters,
      self.collect {|x| x.copy}
    )
  end
  
  # [Overwrites] Returns a duplicate of this realised runtime
  # method.
  #
  def copy
    #result = self.class.new(@usage.copy,*self.collect {|x| x.copy })
    result = self.class.new(@parameters.copy,*self.collect {|x| x.copy })
    #result = self.class.new(nil,*self.collect {|x| x.copy })
    result.scope_id = scope_id
    result.scope = scope
    result.statement_level = statement_level
    result.close
    return result
  end
  
  # TODO  I should use ParseTree to get a list of all the methods - I can then use
  #       that to see what method aren't used and which ones don't have any 
  #       tests.
  
  # Returns an array of the parameters used in this realised runtime 
  # method.
  #
  def params
    return @parameters
  end
  
  # Returns an array of all the variables available at the end of the 
  # method.  This is essentially all the variables available on the
  # last line.  As such the variables scope must be the same as the 
  # method and it should also take into account if any of the variables
  # have been overriden.
  #
  # @param  params              A param container instance that contains the necessary parameters for the
  #                             runtime method instance.
  # @param  additional_methods  An array of runtime method instances that may be
  #                             called by this runtime method.
  # 
  def final_variables(additional_methods=[])

    # TODO  Params should not be needed for realised runtime methods
    # Relise the method - not sure if this strictly nessesary or preferable but I think
    # it might be required to identify variables that are overwritten.
    relised_method = self.copy 

    # Add the passed parameters
    results = params.collect {|x| x.copy}
    
    # Go through each statement that is nested/open etc and find all the declared varibles
    # results = parameters.clone
    relised_method.each do |x|
      next if x.kind_of?(StatementGroup)
      begin
        results.push(x.declared_variable.copy)
      rescue ImproperStatementUsageError => e
        # Catch statements don't declare a variable
        next
      end
    end
    return results
    
  end  
  
end