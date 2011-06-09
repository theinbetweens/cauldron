class BlockContainer < Array
  
  def initialize(*parameters)
    super()
    
    parameters.each { |x| self.push(x) }
  end
  
  def write
    l = '|'
    self.each do |x|
      l += x.write
      l += ', ' unless x.object_id == self.last.object_id
    end
    l += '|'
    return l
  end
  
  def describe
    l = '|'
    self.each do |x|
      l += x.describe
      l += ', ' unless x.object_id == self.last.object_id
    end
    l += '|'
    return l    
  end
    
  def write_with_uniq_id
    l = '|'
    self.each do |x|
      (x.respond_to?('write_with_uniq_id')) ? l += x.write_with_uniq_id : l += x.write
      l += ', ' unless x.object_id == self.last.object_id
    end
    l += '|'
    return l
  end  
  
  # Returns the block variables but with their values next to them.  This
  # presumes that the block container has been realised.
  #
  def write_with_value
    l = '|'
    self.each do |x|
      l += x.write_with_value
      l += ', ' unless x.object_id == self.last.object_id
    end
    l += '|'
    return l     
  end
  
  # TODO  Write tests for this
  def copy
    return BlockContainer.new(*self.collect {|x| x.copy})
  end
  
  # Returns true if all the block variables returned true.
  def realised?
    
    # Go through each of the block variables and determine if they're realised
    return false if self.any? {|x| x.realised? == false }      
    return true
      
  end
  
  # Returns a block container where all the block variables
  # have been realised.
  #
  # I had previously intended to just work out the values for the block
  # but this would create problems when I have blocks within blocks.
  # 
  # NOTE  I have copied code here from the history call in RuntimeMethod
  # 
  def realise(statement,containing_method)
    
    # Create the method to track the change in values of the block variable
    # TODO  I shouldn't need to redeclare this runtime method each time
    #tracking_method = RuntimeMethod.new(MethodUsage.new(MethodParameter.new)) 
    # Create the method that block values are logged to
    instance_tracking_variable = ArrayVariable.new
    instance_tracking_variable.instance_variable = true
    tracking_method = RuntimeTrackingMethod.new(instance_tracking_variable)
    
    raise StandardError.new('This should not be used')
    # Create a method to call the method and return the results
    #process_method = RuntimeMethod.new(MethodUsage.new)
    #process_method << Statement.new( DefCall.new(NilVariable.new) )
    #process_method << Statement.new( Return.new,instance_tracking_variable )    
    
    # CONTINUE Look up the tracking method
    #exit
  end
  
  # Returns an updated block container where all the values for the block
  # have been realised through the method map.
  #
  # @param  method_map    The history of the method that the block container
  #                       is used in.
  #
  def realise2(method_map)
    return self.copy if realised?
    result = BlockContainer.new
    self.each do |x|
      result.push(x.realise(method_map))
    end
    return result
  end
  
  # Returns an array of all the unrealised variables within the 
  # block container.
  #
  def unrealised_variables
    return variables.find_all {|x| x.realised? == false}
  end
  
  # Returns an array of all the variables within this block container.
  #
  def variables
    return self.collect {|x| x.copy}      
  end
  
  # Returns each variable used within the block in turn.
  #
  def each_variable
    variables.each do |x|        
      yield x
    end
  end
  
end
