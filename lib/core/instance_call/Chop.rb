class Chop <InstanceCall
  
  def initialize
    super
    
    @use_requirements = [
      Requirement.new(InstanceCallContainer.new(This.new,ClassCall.new), Equal.new , StringClass.new)
    ]
    
  end
  
  def write
    return '.chop'
  end
  
  def copy
    return Chop.new
  end
  
  def requirements
    @use_requirements.each {|req| yield req}
  end
  
  def use(val)
    return val.chop
  end
  
end