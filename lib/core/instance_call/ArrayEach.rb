
class ArrayEach < InstanceCall
  
  def initialize
    super
  end
  
  def write
    return '.each'
  end
  
  def copy
    return ArrayEach.new
  end  
  
  # Returns false indicating that .each doesn't alter the variable
  # it acts on.
  #
  def destructive?
    return false
  end
  
end