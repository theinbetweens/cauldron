# TODO  Perhaps RuntimeMethodDeclaration might have worked better
#
class RuntimeMethodLiteral
  
  def initialize(usage,return_variable)
    raise StandardError.new('Where is this used')
    @usage = usage
    @return_variable = return_variable
  end
  
  def write
    # TODO  This shouldn't just make up values
    return 'RuntimeMethod.new('+@usage.to_declaration.write+','+@return_variable.to_declaration.write+')'
  end
  
  # TODO  This copy isn't accurate
  def copy
    return RuntimeMethodLiteral.new(@usage.copy, @return_variable.copy)
  end
   
end