class MappingValues < Array
  
  def initialize(array=[])
    super(array)
  end
  
  # TODO  This approach isn't needed anymore
  def -(val)
    if val.kind_of?(MappingValues)
      m = MappingValues.new
      self.each do |x|
        next if val.any? {|y| x.intrinsic_object_id == y.intrinsic_object_id}
        m << x
      end
      return m
    end
    return super
  end    
  
  def copy
    return MappingValues.new(self.collect {|x| x.copy})
  end
  
end