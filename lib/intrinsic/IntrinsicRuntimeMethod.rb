# This represents any reference to main runtime method instance 
# within theories.
#
class IntrinsicRuntimeMethod  < IntrinsicObject
  include Token
 
  def initialize(intrinsic_object_id=nil)
    @intrinsic_object_id = intrinsic_object_id 
    super()
  end
  
  def write
    return 'runtime_method'
  end
  
  def describe
    return '<runtime_method>'
  end
  
  def ==(val)
    if val.kind_of?(IntrinsicRuntimeMethod)
      return true if self.intrinsic_object_id == val.intrinsic_object_id
    end
    super(val)
  end
  
end