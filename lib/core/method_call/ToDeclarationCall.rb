class ToDeclarationCall <InstanceCall
  
  def initialize
    super
  end
  
  def write
    return '.to_declaration'
  end
  
  def copy
    return ToDeclarationCall.new
  end  
  
end