# This is an odd sort of variable because it's actual value
# continually changes when used.  It needs to have a variable
# id to prevent a duplicate variable being created.
#
class BlockVariable < BaseVariable
  
  attr_writer :realised
  
  def initialize
    super()
    
    @realised = false
  end
  
  # Returns a duplicate of the block variable.
  # 
  def copy 
    # @uniq_id should probably be cloned or something
    result = self.class.new() {{:variable_id => self.variable_id,:uniq_id=>@uniq_id, :uniq_id_history=>@uniq_id_history.copy}}
    result.instance_variable = @instance_variable
    self.each do |x|
      result.push(x)
    end
    result.realised = @realised
    return result    
  end
  
  # Returns a string representing the block variable but with all the
  # values of the block variable as well
  def write_with_value
    #return self.write+'('+self.inject {|line,x| line += x.value.write+} +')'
    l  = self.write+'('
    self.each do |x|
      l += x.value.write
      l += '|' unless x.object_id == self.last.object_id
    end
    l += ')'
    return l
  end
  
  # Returns the flag indicating whether the blockvariable had been
  # realised yet.  I can't just use whether all the contained variables
  # are realised as an indication because the block variable may be 
  # empty.  This would indicate either the block itself has no
  # itterations or it hadn't been realised yet.
  #
  def realised?
    return @realised
  end
  
  # Returns a duplicate block variable where all values for the block 
  # variable are included.
  #
  def realise(method_map)
    x = method_map.find_realised_variable(self.variable_id,self.uniq_id,self.class.to_s)
    # Flag the block variable as realised - this needs to be done maually oterwise empty
    # blocks would flaged as realsied.    
    x.realised = true

    return x
  end
  
  # Returns true if the block variable can be used as the specified variable
  # type otherwise it returns false.  It can be used as the specified variable
  # type if all the variables it contains are of that type.
  # 
  # @param  variable_type     The variable type that the block variable is expected 
  #                           to act like e.g. FixnumVariable.
  # 
  def pass_as?(variable_type)
    return self.all? {|x| x.pass_as?(variable_type)}
  end
  
  # This simple returns the block variable.  It is a quick hack so that
  # InstanceCallContainers and variables can be treated in the same way although
  # it is a bit clunck and confusing.
  #
  def variable
    return self
  end
  
  # This writes block variable as a literal.  Now for normal variables this is
  # fine as var_a might become '8' etc.  However block variables have multiple
  # values.  I'm not sure why this is need so for now it will just display
  # the first block variable.
  #
  def to_literal_string
    if empty? then return '' end
    return self.first.to_literal_string
  end  
  
end