
class Equivalent < Assignment
  
  def initialize
    super
  end
  
  def write
    return ' == '
  end
  
  def copy
    return Equivalent.new  
  end
  
  def to_literal_string
    return write
  end  
  
end