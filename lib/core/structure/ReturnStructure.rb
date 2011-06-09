# Returns statements that return values 
#
# Example:
#   return 7
#   return var
#
class ReturnStructure < StatementStructure
  
  def initialize()
    super()
  end
  
  def statements(available=[])
    
    # Create return statements using the passed variables
    return available.collect {|x| Statement.new(Return.new,x.copy)}      
      
  end 
  
end