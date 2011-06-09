class RuntimeMethodParameter < TypeVariable
  
  def initialize(val)
    super(val)
  end
  
#  def copy
#    copied = self.class.new(@value)
#    copied.variable_id = self.variable_id
#    return copied
#  end  
#  
  # Only let this method be called from fellow Fixnum classes or Unknowns
  def variable_id=(id)
    # TODO  I need a better way to restrict access to this
    # TODO  This would be nicer if it wasn't so hard coded ./lib/core/variable/Unknown.rb
    #unless caller.first.split(':')[0]==__FILE__ or caller.first.split(':')[0]=='./lib/core/variable/Unknown.rb'
    #  raise StandardError.new('Illegal attempt to set variable_id')
    #end
    @variable_id = id
  end
  
  # Returns an array of instance calls that are possible given the 
  # provided variables.
  # 
  # @param  available   
  #
  def instance_calls(available=[],used_in_declaration_statement=false)
    results = []

    # Create runtime_method.push(runtime_value)                 
    ##  Find all the statement variables
    available.find_all {|x| x.kind_of?(StatementVariable)}.each do |y|
      #results.push(InstanceCallContainer.new(self.copy,PushStatement.new,y.copy))    
      # TODO  What is PushStatement for
      results.push(InstanceCallContainer.new(self.copy,Push.new,y.copy))    
    end
    return results             
  end
  
  # Returns an array of instances calls that return a value and are 
  # therefore approriate for declaration statements. 
  # 
  # NOTE  Although .push does return a value I have excluded it because 
  #       I want to limit the number of variables declared.
  #
  def returning_instance_calls(available)
    return []  
  end
  
  # Returns an array of desctructive instance calls given the available
  # variables.
  # 
  # @param  available     An array of other variables that can be used as
  #                       parameters. 
  #
  def destructive_instance_calls(available=[])
    return instance_calls(available)
  end
  
#  # Returns a declaration variable for this runtime method variable. 
#  #
#  def to_declaration
#    return VariableDeclaration.new(RuntimeMethodParameter)
#  end  
  
end