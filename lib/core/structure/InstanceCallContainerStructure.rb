# Example
#   e.g. 'test'.chop
#   e.g. 'test'.chop!
#
class InstanceCallContainerStructure < StatementStructure

  def initialize()
    super()
  end
  
  # Returns an array of possible statements that make an instance 
  # call.  They don't declare a new variables so to be in any way 
  # relevant they must be destructive e.g.
  # 
  # 'test'.chop   # essential does nothing
  # 'test'.chop!  # Changes the value  ('test' represents a variable with that value)
  #
  def statements(available=[])

    # Exclude method calls for now - avoiding too complex statements
    available.delete_if {|x| x.kind_of?(DefCall)}

    # Go through each method call available to each of the variables
    results = []
    available.copy.each do |subject_var|

      # Duplicate the available variables and exclude the current one
      # to avoid less predicatable statements.
      current_available = available.copy.delete_if do |x| 
        unless(x.kind_of?(Variable) and subject_var.kind_of?(Variable))
          next false
        end
        x.variable_id == subject_var.variable_id
      end

      # Create statements that use the specified instance calls
      subject_var.destructive_instance_calls(current_available).each do |inst_call|
        new_statement = Statement.new(inst_call)

        # TODO  I'm not sure if all the instance calls are modifying - I should may have a StatementTemplate
        #       class that foces the {:review} to be false.
        #new_statement.statement_type = MODIFYING_STATEMENT
        results.push(new_statement)
      end
    end

    return results
  end
  
end