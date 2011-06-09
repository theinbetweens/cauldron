# Not sure how or is this class will be used but it is meant as contextual 
# reference to a different instance.
# 
# TODO  Check whether this needs to be an array
#
class This < Array
  
  #
  # @param  method_call     The name of any method call if any.   For example:
  #                         self.class  
  #
  def initialize(*parameters)
    super()
    
    # Save any requirements
    parameters.collect {|param| self.push param}
  end
  
  # @param  variable    The variable "self" refers to.  This is dependent on
  #                     where the instance is used.
  #
  def write(context=nil,variable=nil)
    if context.nil? then return 'self' end
    if variable.nil? then return 'self' end            
    return context.display_name_for(variable)
  end
  
  def describe(context=nil,variable=nil)
    return write(context,variable)+"\n"
  end
  
  def copy
    return This.new
  end
  
  def declaration_statement
    return ClassMethodCallContainer.new(ThisClass.new,New.new)
  end
  
end