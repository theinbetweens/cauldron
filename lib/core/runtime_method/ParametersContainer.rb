# TODO  I think this class is pretty pointless - I should try and drop it
class ParametersContainer < Array
  
  # TODO  Should this be able to write parameters?
  
  def initialize(*params)
    super()  
    params.each do |x|
      self.push(x)
    end
  end
  
  def variables
    return self
  end
  
  def each_variable
    self.each do |x|
      yield x
    end
  end
  
  # Creates a duplicate of this parameters container.
  #
  def copy
    return ParametersContainer.new(*self.collect {|x| x.copy})
  end
  
end