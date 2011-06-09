class RequirementClass < ClassName
  
  def initialize
    super
  end
  
  def write(context=nil)
    return 'Requirement'
  end  
  
  def copy
    return RequirementClass.new
  end
  
  def value
    return Requirement
  end
    
end