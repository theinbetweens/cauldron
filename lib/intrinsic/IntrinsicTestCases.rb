class IntrinsicTestCases < IntrinsicObject
  include Token
  
  def initialize(intrinsic_object_id=nil)
    @intrinsic_object_id = intrinsic_object_id 
    super()
  end
  
  def write
    return 'test_cases'
  end  
  
  def describe
    return '<test_cases>'
  end  
  
end