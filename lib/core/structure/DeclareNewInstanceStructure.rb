# Returns statements that declare new instances of the available classes
# 
# Example:
#   var_a = MethodUsage.new
#   var_b = RuntimeMethod.new(var_a)
#
class DeclareNewInstanceStructure < StatementStructure
  
  #
  # @param  available_classes   Any number of class instances that can be used
  #                             when generating statements, e.g. MethodUsageClass.new
  #
  def initialize(*available_classes)
    super()
    available_classes.each {|x| self.push(x)}
  end
  
  # Returns an array of instance declaration statements using
  # the available variables.
  #
  # @param  available     An array of variables that are made available 
  #                       when declaring new statements.
  #
  def statements(available=[])
    
    # Get all the various arrangements of parameters at all the lengths (capped at 5)
    arrangements = [[]]
    
    # Add one of each available variable
    available.each do |x|
      arrangements.push([x])
    end
    
    # For each arrangement create a new statement declaration
    results = []
    
    # Create a number of declaration statements using the method classes
    # e.g. Unknown.new,Equal.new,ClassMethodCallContainer.new(MethodUsageClass.new,New.new)
    self.each do |x|
      x.class_method_calls(available).each do |y|
        new_statement = Statement.new(Unknown.new,Equal.new,y)
        results.push(new_statement)
      end
    end
    
    return results
  end 
  
end