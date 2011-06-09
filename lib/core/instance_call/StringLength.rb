class StringLength < InstanceCall
  
  def initialize
    super
    
    @use_requirements = [
      Requirement.new(InstanceCallContainer.new(This.new,ClassCall.new), Equal.new , StringClass.new)
    ]    
    
  end
  
  def write
    return '.length'
  end
  
  def copy
    return StringLength.new
  end
  
  def requirements
    @use_requirements.each {|req| yield req}
  end
  
  def use(val)
    return val.length
  end  
  
  def to_literal_string
    return write
  end
  
end