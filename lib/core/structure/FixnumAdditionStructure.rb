# Example
#   e.g. var_a = var_b + var_c
#
class FixnumAdditionStructure < StatementStructure
  
  def initialize()
    super([Unknown,Equal,FixnumVariable,Addition,FixnumVariable])
  end
  
  # Returns an array of statements using the available variables that
  # follow the structure var = 8 + 6
  #
  # @param  available     An array of runtime variables that can be used in the statements
  #                       construction.
  #
  def statements(available=[])
    
    # If there aren't any fixnum variables there is nothing to return
    return [] unless available.any? {|x| x.pass_as?(FixnumVariable)}    
    
    # First find just varaibles that can pass as FixnumVariables
    # NOTE: Currently I am not allowing method calls to be used
    fixnum_variables = available.find_all {|x| x.pass_as?(FixnumVariable) and !x.kind_of?(DefCall)}
    
    # Using the variables constuct statements
    possible_statements = []
    fixnum_variables.length.times do |x|
      fixnum_variables.length.times do |y|
        new_statement = Statement.new(Unknown.new,Equal.new,fixnum_variables[x].copy,Addition.new,fixnum_variables[y].copy)
        #new_statement.statement_type = DECLARATION_STATEMENT       
        possible_statements.push(new_statement)
      end
    end
    
    # Remove mirror statements - these are additions that are essentially the 
    # same statement written backwards.
    # e.g.  var_c = var_a+var_b
    #       var_d = var_b+var_a
    possible_statements.copy.each do |x|
      possible_statements.copy.each do |y|
        next if x.statement_id == y.statement_id
        if y.same_not_declared_variables?(x)
          
          # If the first variable id is lower than the secound remove it.    
          if y[2].variable_id < y[4].variable_id
             possible_statements.delete_if {|z| z.statement_id == y.statement_id}
          end
        end
      end
    end
    
    return possible_statements
        
  end
  
end