class ActionImplementation < TheoryAction
  
  attr_reader :target_id
  
  def initialize(statement,target_id,theory_component_id=nil)
    super(statement,target_id,theory_component_id)
  end
  
  def copy
    return ActionImplementation.new(@action.copy,@target_id.copy,@theory_component_id)
  end
  
  def write(tab=0)
    return ("  "*tab)+"runtime_method.add_statement_at(#{@action.write},#{@target_id.write})"
  end    
  
end