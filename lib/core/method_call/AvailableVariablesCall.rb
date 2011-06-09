class AvailableVariablesCall < InstanceCall
  include WriteParameters
  
  def initialize(*parameters)
    super(*parameters)
    
    # The requirements for the instance use this method call
    @use_requirements = [Requirement.new(InstanceCallContainer.new(This.new,ClassCall.new), Equal.new , RuntimeMethodClass.new)]    
    
  end

  def write
    return '.available_variables'
  end
  
  # TODO  Test this method works
  def copy
    return self.class.new(*self.collect {|x| x.copy})
  end
  
  def requirements
    @use_requirements.each {|req| yield req}    
  end    
    
end