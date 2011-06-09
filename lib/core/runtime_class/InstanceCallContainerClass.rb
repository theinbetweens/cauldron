class InstanceCallContainerClass < ClassName
  
  def initialize(*params)
    super
    params.each {|x| self.push(x)}
  end
  
  def copy
    return InstanceCallContainerClass.new
  end  
  
  def write(context=nil)
    return 'InstanceCallContainer'
  end  
  
end