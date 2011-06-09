# Contains the usage history of a method, or a statement group etc. The current structure is
# something like the following:
#
# [0] = {line:1,available_variables:[var_0,var_1],action:"'test'"}
# [1] = {line:2,available_variables:[var_0,var_1,var_2],action:"'test'.chop"}
#
# Actually the history object should probably save what happens to variables at
# each line aswell.  Although I should frame this in a example so I rember.
# 
# One of the purposes of the history object is to refactor code.  So
# if I have three chop statements.
# 
# var_0 = 'test'
# var_1 = var_0.chop
# var_2 = var_1.chop
# var_3 = var_2.chop (ending with var_3 = 't')
#
# Now I'm to abstract that process so I come up with the method
# 
# var_0 = 'test'
# 3.times do |i|
#   var_0 = var_0.chop
# end
# 
# In both cases they end up with a value of 't' but how can we be sure that 
# replacing one process with the other is equivalent?  Well of course they're 
# not identical and I am tempted to just use there final value but I would
# be concerned with the likes of numbers for example the number 2.
#
# What about if I consider them as literal values.  Then their history can be
# expressed.
#
# 'test' -> 'test'.chop -> 'tes'.chop -> 'te'.chop -> 't'
#
class History < Array
  
  def initialize(*paramaters)
    super()
    self.each do |x|
      self.push(x)
    end
  end
  
  # Create a copy of the history instance.
  #
  def copy
    return History.new(*self.collect {|x| x.copy} )  
  end
  
  def cauldron_method_calls
    result = ['.length','.any?']
    return result
  end  
  
  # Returns an array of steps that include the variable 
  # specified.
  #
  # @param  id      The id of the variable that should be included in all the 
  #                 returned steps.
  #
  def find_steps_with_variable(id)
    results = []
    self.each do |x|
      results.push(x) if x['variables'].any? {|y| y['id'] == id}
    end
    return results
  end
  
  # Returns the values for the unique variable id specified.  NOTE
  # it is important to use the unique variable id to avoid any
  # mistaken interpretation.
  #
  # TODO  This should be using unique_variable id to avoid the risk of 
  #       miss interpretation
  #
  def find_value_for(variable_id)
    results = []
    
    # Find all the values for the particular id
    self.each do |x|
      results += x['variables'].find_all {|y| y['id']==variable_id}
    end
    return results.first['value']

  end
  
  # Returns a realised variable reflecting the id supplied.  It 
  # can be either a VariableContainer, TypedVariable and BlockVariable.
  #
  # TODO  I still havn't properly worked how to distinguish between types of variables
  #
  # @param  variable_id     The variable id that should be realised and returned
  # @param  variable_type   A string indicating the type of variable that is being 
  #                         realised.  This is basically used to distinguish between
  #                         block variables and variable containers.  NOTE if the variable
  #                         doesn't have multiple values it won't be VariableContainer - just
  #                         a type variable.
  # 
  def find_realised_variable(variable_id,uniq_id,variable_type='VariableContainer')
        
    raise StandardError.new('Expecting Fixnum') unless uniq_id.kind_of?(Fixnum)

    # Find all the values for the particular id
    # TODO  Because there is a step class I could use more custom methods
    results = self.inject([]) do |total,x|
      total += x['variables'].select {|y| y['uniq_id'] == uniq_id}
      total
    end
    
    # If all values have the same absolute id return a type variable.
    # (this means the value of the variable doesn't change through the method)
    if results.all? {|x| x['abs_id']==results.first['abs_id']}     
      raise StandardError.new('Unable to find variable with id '+variable_id.to_s+' and uniq_id '+uniq_id.to_s) if results.empty?
      
      # TODO  I don't know how to handle the situation where I have a reference to 
      #       a variable.  So the value of var_570 points to the UnkownVariable.  In
      #       which case we have a UnknownVariable - which is just getting
      #       a bit rediculous.
      #  #
      #  #    
      #  def method_8
      #    var_12 = Statement.new(Unknown.new,Equal.new,8.to_declaration) 
      #    var_570 = var_12.declared_variable 
      #  end
      # TODO  This better track mulitple values - I should at least indicate them
      return results.first['value'].to_var(variable_id,uniq_id)

    end
    
    raise StandardError.new('variable '+variable_id.to_s+' has multiple values but no variable_type was supplied') if variable_type.nil?

    case variable_type
      when 'BlockVariable'

        # Find all the unique variable ids
        unique_results = []
        results.each do |x| 
          unique_results.push(x) unless unique_results.any? {|y| y[:abs_id] == x[:abs_id]}
        end
        
        # Convert each result into a variable and return a new block variable
        new_block_variable = BlockVariable.new() {{:variable_id=>variable_id,:uniq_id=>uniq_id}}
        unique_results.each do |x|
          new_block_variable.push(x[:value].to_var(variable_id))
        end
        return new_block_variable
        
      when 'VariableContainer'
        
        # Find all the unique variable ids
        unique_results = []
        results.each do |x| 
          unique_results.push(x) unless unique_results.any? {|y| y[:abs_id] == x[:abs_id]}
        end
        
        # Convert each result into a variable and return a new block variable
        # TODO  This should probable include the uniq_id as well
        new_container_variable = VariableContainer.new() {{:variable_id=>variable_id,:uniq_id=>uniq_id}}
        unique_results.each do |x|
          new_container_variable.push(x[:value].to_var(variable_id))
        end
        return new_container_variable
     end
    raise StandardError.new('Method not able to handle different type of variables') 
  end
  
end