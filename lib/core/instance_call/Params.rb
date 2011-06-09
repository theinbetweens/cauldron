class Params < InstanceCall
  
  def initialize
    super
  end
  
  def write
    return '.params'
  end
  
  def copy
    return Params.new
  end
  
end