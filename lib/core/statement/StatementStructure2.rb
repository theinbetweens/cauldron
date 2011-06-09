# Move this class to the structure folder
# 
# TODO  This is more a StatementStructureFactory
class StatementStructure2 < Array
  
#  attr_reader :declared_fixnum
#  
#  @@DECLARED_FIXNUM = 'declared_fixnum'
#  DECLARE_STRING = 'declared_string'
#  DECLARE_STRING_ADDITION = 'declared_string_addition'
  TIMES_ON_FIXNUM = 'times_on_fixnum'
  
  # TODO  I don't think I really need to pass the parameters anymore
  def initialize(name)
    # TODO  What are the two parameters an array expects
    super()
    
    @structure_name = name

    # Add the parameters to the array 
    structure().each do |code|
      self.push(code)
    end    
  end
  
  # var = 'test'+'ing'
  def StatementStructure2.declared_string_addition
    return 'declared_string_addition'
  end
  
  def StatementStructure2.times_on_fixnum
    return 'times_on_fixnum'
  end
  
  def StatementStructure2.declared_array
    return 'declared_array'
  end
  
  def StatementStructure2.declared_runtime_method
    return 'declared_runtime_method'
  end
  
  # var = 5+8
  def StatementStructure2.declared_fixnum_addition
    return 'declared_fixnum_addition'
  end
  
  def StatementStructure2.declared_statement
    return 'declared_statement'
  end
  
  def structure
    case @structure_name
#      when StatementStructure2.declared_fixnum
#        return [Unknown,Equal,FixnumVariable]
#      when StatementStructure2.declared_string
#        return [Unknown,Equal,StringVariable]
      when StatementStructure2.declared_array
        return [Unknown,Equal,ArrayVariable]
      when StatementStructure2.declared_runtime_method
        return DeclareRuntimeMethodStructure.new()
      when StatementStructure2.declared_string_addition
        return [Unknown,Equal,StringVariable,Addition,StringVariable]
      when StatementStructure2.declared_fixnum_addition
        return FixnumAdditionStructure.new()
      when StatementStructure2.declared_statement
        return DeclareStatementStructure.new()
    else
      raise StandardError.new('Unknown statement structure "'+@structure_name+'"')
    end
  end
  
  # Returns an array of possible statements that can be
  # created to follow the structure of the statement.
  #
  # Any method calls are considered as their returned value. So
  # a method that returns a string is just considered as a 
  # RuntimeVariable with a string class requirement.
  #  
  def statements(available=[])
    
    # Retrieve the statements for 
    if(@structure_name==StatementStructure2.times_on_fixnum)
      return fixnum_times_statements(available)
    end
    
    # Create an array of statements that gets extended
    partial_statements = [Statement.new]
    
    # Go through each element of the statement structure
    self.each do |statement_element|
      
      # Creates an array of updated statements
      updated_statements = []
      
      # If it is an unknown variable just add it 
      if(statement_element == Unknown)
          partial_statements = add_unknown_variable(partial_statements)
          next
      end
      
      # Just include it if it's a = sign
      if(statement_element == Equal)or(statement_element == Addition)
      
          # Go through each element in the partial statements and add a copy of the new element
          partial_statements.each do |partial|              
            copied_statement = partial.copy
            copied_statement.push(statement_element.new)
            updated_statements.push copied_statement
          end
          partial_statements = updated_statements          
          next
      end      
      
      # Go through each of the available elements and see if they meet the statement elements
      available.each do |avail|
        
        # If any of the values match - include them in the statement
        if avail.kind_of?(statement_element)
          
          # Go through each element in the partial statements and add a copy of the new element
          partial_statements.each do |partial|              
            copied_statement = partial.copy
            copied_statement.push(avail.copy)
            updated_statements.push copied_statement
          end
              
        end
        
        # Now see what instance calls are available to the passed avail
        if avail.kind_of?(Variable)
          
          # Retrieve any instance calls available for that variable
          # TODO  Availabe should not include the variable with the same id
          instance_calls = avail.instance_calls(available)
          instance_calls.each do |x|

            if x.response.class == statement_element
                
              partial_statements.each do |partial|              
                copied_statement = partial.copy
                copied_statement.push(x.copy)
                updated_statements.push copied_statement
              end                            
                
            end
          end
              
        end
        
        # If it is a definition call then check against the response value
        if avail.kind_of?(DefCall)
          if avail.response.class == statement_element
            partial_statements.each do |y|
              copied_statement = y.copy
              copied_statement.push(avail.copy)
              updated_statements.push copied_statement
            end
          end
        end
        
      end
      
      partial_statements = updated_statements
      
    end
    
#    # Save the structure used to create the statement - this structure type will 
#    # become deprecated soom.
#    partial_statements.each do |x|
#      x.structure = self.class
#    end

    return partial_statements     
     
  end
 
  # Returns a general description of the statement to 
  # indicate whether it declares a new variable or 
  # modifies an existing variable or nothing.
  #
  def self.statement_type
    #raise StandardError.new('This method should be overridden "'+self.to_s+'"')
    StandardLogger.instance.warning('This method should be used')
    #return StatementStructure.DECLARATION_STATEMENT
    return 'declaration_statement'
  end 

protected 
  
  # TODO Write tests
  # Adds a unknown variable to each statement in the supplied 
  # array and returns the result.
  #
  def add_unknown_variable(current_statements)
    results = []
    current_statements.each do |x|              
      copied = x.copy
      copied.push(Unknown.new)
      results.push copied
    end    
    return results
  end
  
  # Get the possible .times statements from the available
  # fixnum variables 
  #
  def fixnum_times_statements(available=[])
    
    # If there aren't any fixnum variables there is nothing to return
    return [] unless available.any? {|x| x.kind_of?(FixnumVariable)}

    # Use each of the fixnum variables
    results = []
    available.find_all {|x| x.kind_of?(FixnumVariable) }.each do |y|  
      new_statement = BlockStatement.new(Statement.new(InstanceCallContainer.new(y.copy,Times.new)),BlockContainer.new(BlockVariable.new))
      new_statement.structure = self.class
      results.push(new_statement)
    end

    return results
  end
  
end