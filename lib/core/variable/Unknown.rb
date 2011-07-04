#require $LOC+File.join(['lib','core','variable','Variable'])
# TODO  This is not strickly a Variable - it is a data type of it's own

class Unknown < BaseVariable
  alias :variable_push :push
  
  # TODO  I think requirements here can be dropped
  def initialize(*requirements)
    super(*requirements)
  end
  
  # Adds a new requirement to the unknown variable.  Unlike
  # variables requirements can be added from outside the
  # instance.
  #
  def push requirement
    variable_push requirement
  end
  
  # Returns a typed version of the variable with the correct
  # variable id.  This occurs when an Unknown variable is 
  # used in a statement and its value can be determined.
  #
  def classify(value)
    case value.class.to_s
      when 'String'
        var = StringVariable.new(value)
        var.variable_id = variable_id
        return var
      when 'Fixnum'
        var = FixnumVariable.new(value)
        var.variable_id = variable_id
        return var
    else
      raise StandardError.new('Unknown data type '+value.class.to_s)
    end
  end
  
  # TODO  Test this
  # TODO  Should 'Unknown' have a variable id
  def copy  
    result = self.class.new(*self) {{:variable_id => variable_id,:uniq_id=>@uniq_id,:uniq_id_history=>@uniq_id_history.copy}}
    result.instance_variable = @instance_variable
    return result
  end  
  
#
  def describe(tab=0,context=self)
    
    # Create a temporay copy of the variable
    copied_var = self.copy

    unless context == self
      
      # Return a duplicate variable with the requirements in the context indicated
      copied_var = context.contextual_variable(copied_var.variable_id)
      
    end
    
    # Print the name of the variable
    line = ''    
    line += write
    
    # Print out each of the requirements
    copied_var.each do |x|        
      desc = x.describe(context)
      desc.each_line do |l|
        line += "\t"+l
      end      
      line += "\n" unless x == copied_var.last      
    end
    line += "\n"
    
    return line
    
  end  
  
  # Returns a copy of the variable, this method exists in the
  # instance call class.  It avoids distinguishing the two.  
  # Since variale is lowest level context doesn't matter.
  #
  def copy_contextual_variable
    return copy
  end  
  
  def to_literal_string
    return 'var'  
  end
  
  def realised?
    return false
  end
  
  def to_declaration
    return VariableDeclaration.new('Unknown')
  end
  
  def to_var(id=nil,uniq_id=nil)
    StandardLogger.instance.warning('"Unknown" is NOT a variable - it is a data type')
    #super(id)
    return UnknownVariable.new(self) {{:variable_id => id,:uniq_id=>uniq_id}}
  end
  
  # Unknown variables are evaluated are runtime so as along as it is
  # a variable it is probably fine.
  #
  def equivalent?(to)
    return true if to.kind_of?(BaseVariable)
    return false
  end
  
end