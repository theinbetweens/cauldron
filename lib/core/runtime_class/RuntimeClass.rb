# TODO  I'm not sure this shuld be here - it doesn't represent a runtime class - RuntimeClassClass does this
class RuntimeClass < Array
  attr_reader :class_name
  #
  # @param  name          The name of the runtime class
  # @param  parameters    
  #
  def initialize(name,*parameters)
    super()
    
    # Save a name for the runtime class
    @class_name = name
    
    # Add the parameters to the array 
    parameters.each do |x|
      self.push(x.copy)
    end    
  end
  
  def write
    result = ''
    result += "class #{@class_name}"+"\n"
    self.each do |x|
      result += x.write
    end
    result += 'end'
    return result
  end
  
end