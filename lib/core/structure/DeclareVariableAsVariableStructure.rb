# NOTE: I'm not certain whether these types of strucutres are actually necessary
# but they did exist when I was using StatementStrucuture2.rb
# 
# Example
#
# var_b = var_a
# var_c = var_b
# var_e = var_b.chop

class DeclareVariableAsVariableStructure < StatementStructure
  
  def initialize()
    super([Unknown,Equal,TypeVariable])
  end    
  
  # Returns an array of statements constructed using the supplied
  # variables. 
  #
  def statements(available=[])
    return [] if available.empty?
    variables = available.select {|x| x.kind_of?(TypeVariable)}

    # Generate all the possible direct variable declarations e.g. var_a = var_b
    direct_declarations =  variables.collect {|x| Statement.new(Unknown.new,Equal.new,x.copy)} 
    
    # Generate all the possible instance call declarations - I'm not sure if this will be used in this way
    results = variables.collect do |x|
      result = x.returning_instance_calls(available).collect do |y| 
        Statement.new(Unknown.new,Equal.new,y)
      end
    end
    
    # TODO  This seems a bit sloppy - I should do it in a nicer way
    instance_call_declarations = []
    results.each do |x|
      x.each {|y| instance_call_declarations.push(y)}
    end
    
    # Find all the possible method calss
    # TODO  Write tests for this method call bit
    # TODO  This doesn't allow for parameters
    available.each do |x|
      if x.kind_of?(DefCall)
         instance_call_declarations.push(Statement.new(Unknown.new,Equal.new,x.copy))
      end
    end    
  
    return direct_declarations.concat(instance_call_declarations)
    
  end
  
end