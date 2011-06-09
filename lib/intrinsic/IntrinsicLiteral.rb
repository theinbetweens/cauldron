class IntrinsicLiteral < IntrinsicObject
  include Token
  
  def initialize(value,intrinsic_object_id=nil)
    @intrinsic_object_id = intrinsic_object_id
    super()
    @value = value
  end
  
  def write
    @value.write
  end  
  
  def describe
    @value.describe
  end  
  
  def copy
    return IntrinsicLiteral.new(@value,@intrinsic_object_id)
  end    
  
  def literal
    return @value
  end
  
end