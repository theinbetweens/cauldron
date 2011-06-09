# This class represent calls to availble functions.  This could be 
# custom generated method calls e.g.
#
# m1
#
# if there was a method that looked like
# 
# def m1
#   # do something
# end
#
# it could also be core ruby calls
# 
# TODO  Write tests for this
#
class DefCall <InstanceCall
  include WriteParameters
  
  # TODO  I'm still undecided on whether DefCall should have a scope id or not
  attr_reader :runtime_method, :scope_id
  attr_writer :scope_id
  
  #
  #                     TODO  I suspect response isn't needed any more or at least should be the secound parameter
  # @param  response    What is returned by the method - 
  # 
  def initialize(response,runtime_method,*parameters)
    super(*parameters)
    raise StandardError.new('Should be a runtime method instance') unless runtime_method.kind_of?(ActsAsRuntimeMethod)
    @response = response.copy
    @runtime_method = runtime_method.copy

  end
  
  def write
    l = @runtime_method.method_name
    l += write_params(self)
    return l
  end
  
  def describe
    x = 'Call: '+write
    return x
  end
  
  def copy
    return DefCall.new(@response.copy,@runtime_method.copy,*self.collect {|x| x.copy})
  end
  
  def response
    return @response.copy
  end  
  
  # Returns true if the method call can pass as specified variable_type.  This
  # bascially depends on what the method call returns.
  # 
  # @param  variable_type   The variable type the method call will be treated as.  For
  #                         example FixnumVariable.
  # 
  def pass_as?(variable_type)
    return @response.pass_as?(variable_type)
  end
  
  def equivalent?(to)
    return false unless to.class == self.class
    # TODO  I should also include a method_interation value here - this should increment each time the 
    #       the runtime method recieves a new statement because it essentially becomes a different method.
    return true if @runtime_method.method_id == to.runtime_method.method_id
    return false    
  end
  
end