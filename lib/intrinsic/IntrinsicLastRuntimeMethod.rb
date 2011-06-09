# This represents any reference to main runtime method instance 
# within theories.
#
class IntrinsicLastRuntimeMethod  < IntrinsicObject
  include Token
 
  def initialize(intrinsic_object_id=nil)
    @intrinsic_object_id = intrinsic_object_id
    super()
  end
  
  def write
    return 'last_runtime_method'
  end
  
  def describe
    return '<last_runtime_method>'
  end
  
end