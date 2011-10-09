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
