# TODO  I think this structure has been super seeded by DeclareVariableAsVariableStructure
# Example - where the method_a returns a RuntimeMethod instance
# 
# var_a = method_a()
#
class DeclareRuntimeMethodStructure < StatementStructure
  
  def initialize()
    super([Unknown,Equal,RuntimeMethodParameter])
  end  
  
  # Returns an array of possible statements that can be created
  # using the available variables.  Currently the only way to 
  # create runtime method instances is via a separate runtime
  # method call.
  #
  # @param  available     An array of variables that can be used to 
  #                       to create the statements that declared new
  #                       runtime variables.
  #
  def statements(available=[])
    return [] if available.empty?
    def_calls = available.find_all {|x| x.kind_of?(DefCall)}
    results = []
    def_calls.each do |x|
      if x.response.class == RuntimeMethodParameter
        new_statement = Statement.new(Unknown.new,Equal.new,x.copy)
        results.push(new_statement)
      end
    end
    return results
  end
  
end