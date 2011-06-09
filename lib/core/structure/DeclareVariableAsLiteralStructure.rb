#
# Example
#
# var = 6
# var = 'Shepard'
# var = []
# 
class DeclareVariableAsLiteralStructure < StatementStructure
  
  def initialize(*available_literals)
    super([Unknown,Equal,Literal])
    @available_literals = available_literals
  end  
  
  # TODO  Write tests for this
  # Returns an array of possible statements that can be created
  # given the variables supplied.
  #
  # @param  available   An array of possible variables that can be used to generate 
  #                     new statements.  Although for this structure it is only
  #                     interested in the literals.
  #
  def statements(available=[])
    combined_available = @available_literals + available
    return [] if combined_available.empty?
    literals = combined_available.find_all {|x| x.kind_of?(Literal)}
    results = literals.collect {|x| Statement.new(Unknown.new,Equal.new,x) }
    return results
  end    
  
end