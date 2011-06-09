class StatementLiteral
  
  # TODO  I might not need the RuntimeMethodLiteral or StatementLiteral classes - I could just
  #       use the creation command.
  
  # 
  #
  def initialize(statement)
    @statement = statement
  end
  
  # 
  # 
  def write
    l = 'Statement.new('
    @statement.each do |x|
      l += x.creation
      l += ',' unless x.object_id == @statement.last.object_id
    end
    l += ')'
    return l
  end
  
  def copy
    return StatementLiteral.new(@statement.copy)
  end
  
end