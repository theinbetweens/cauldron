# TODO  It is probably a bit overkill to create a new class for this.
#
# This is the same as the block statement except it uses the curly bracket syntax
#
class SingleLineBlockStatement < BlockStatement
  
  def initialize(statement,block_container=BlockContainer.new(BlockVariable.new),*internal_statements)
    super(statement,block_container,*internal_statements)
  end    
  
  def write(tab=0)
    l = @statement.write(tab)+'{ '+@block_container.write+' '
    self.each do |x|
      l += x.write
    end    
    l += '} '
    return l
  end  
  
  def describe(tab=0)
    l = @statement.describe(tab)+'{ '+@block_container.describe+' '
    self.each do |x|
      l += x.describe
    end    
    l += '} '
    return l
  end   
  
  def copy

    result = SingleLineBlockStatement.new(@statement.copy,@block_container.copy,*self.collect {|x| x.copy})  
    # TODO  This means the scope id is being incremented for statements only exist for the declaration
    result.scope_id = scope_id
    result.scope = scope.copy
    result.statement_level = statement_level
    return result
  end  
  
end 