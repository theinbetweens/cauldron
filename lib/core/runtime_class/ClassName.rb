class ClassName < Array

	def initialize
	end
  
  def describe
    return write
  end
  
  def to_literal_string
    return self.write
  end
  
  def copy
    return self.class.new
  end    
  
end