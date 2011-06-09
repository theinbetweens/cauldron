class IntrinsicObject
  
  attr_reader :intrinsic_object_id
  
  def initialize
    generate_intrinsic_object_id
  end
  
  @@intrinsic_object_id = 0
  
  def generate_intrinsic_object_id
    if @intrinsic_object_id.nil?
      @intrinsic_object_id = @@intrinsic_object_id
      @@intrinsic_object_id += 1
    end
  end    
  
  def copy
    return self.class.new(@intrinsic_object_id)
  end    
  
end