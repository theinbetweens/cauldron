class New < RuntimeClassMethodCall
  
  def initialize
    super()
  end
  
  def write
    return '.new'
  end
  
  def copy
    return New.new
  end
  
end