# TODO  Come up with a better solution that all these bloody classes!
class ReturnClass < ClassName
  
  def initialize
    super 
  end

  def write(context=nil)
    return 'Return'
  end
  
  # TODO  Decide whether this should be ReturnClass.new or Return.new see FixnumClass
  def copy
    return ReturnClass.new
  end

  def value
    return Return
  end
  
end