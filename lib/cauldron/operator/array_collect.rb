class ArrayCollect

  def initialize
    
  end

  def to_ruby(operator = nil)
    return "  var0.collect { |x| x }" if operator.nil?
    "  var0.collect { |x| #{operator.to_ruby('x')} }"+"\n"
  end

end