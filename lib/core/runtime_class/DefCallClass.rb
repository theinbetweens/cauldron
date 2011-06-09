# TODO  Come up with a better solution that all these bloody classes!
class DefCallClass < ClassName
  
  def initialize
    super 
  end

  def write(context=nil)
    return 'DefCall'
  end
  
  # TODO  Decide whether this should be ReturnClass.new or Return.new see FixnumClass
  def copy
    return DefCallClass.new
  end

  def value
    return DefCall
  end
  
end