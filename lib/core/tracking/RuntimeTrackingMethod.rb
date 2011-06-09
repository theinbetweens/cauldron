# This is a special runtime method that is used to track changes in a method
# as it is being run. 
# 
# The call to the tracking method looks something like this:
#
# tracking_method(line,action,variables=[])
#
class RuntimeTrackingMethod < RuntimeMethod
  
  #
  # @param  instance_tracking_variable   The instance variable that contains each tracked event.
  #
  def initialize(instance_tracking_variable)
    @line = MethodParameter.new
    @statement_id = MethodParameter.new    
    @variables = MethodParameter.new
    @action = MethodParameter.new
    super( MethodUsage.new(@line,@statement_id,@variables,@action) )

    # Add the statements that are used in the tracking method    
    self.push HackStatement.new(instance_tracking_variable.write+' = History.new if '+instance_tracking_variable.write+'.nil?')
    x = instance_tracking_variable.write+".push(Step.new(
      #{@line.write},    
      #{@statement_id.write},      
      #{@variables.write},         
      #{@action.write}
     ))"
    self.push HackStatement.new(x)
     
  end
  
end