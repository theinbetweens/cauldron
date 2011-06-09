class Array
  
  def cauldron_method_calls
    # TODO  Need to follow sexp more for ArrayAccess - I shouldn't need a class to contain the array and value
    #result = self.length.times.collect {|x| '['+x.to_s+']'}
    #result = self.length.times.collect {|x| ArrayAccess.new(self.copy,x)}
    result = ['.length','.any?','[]']
    return result
  end
  
  def to_var(id=nil,unique_id=nil)
    raise StandardError.new('No to_var method has been created for '+self.class.to_s) unless self.class.to_s == 'Array'
    # TODO I'm not sure whether it's best to save the literal value or variable value
    result = []
    self.each {|x| result.push(x.copy)}    
    replicate = ArrayVariable.new(*result) {{:variable_id => id,:uniq_id=>unique_id}}
    return replicate
  end  
  
  # Returns the array as a declaration string
  # e.g.  ['lions','tigers','bears'] becomes "['lion','tigers','bears']"
  #
  def to_declaration
    raise StandardError.new('No to_declaration method has been created for '+self.class.to_s) unless self.class.to_s == 'Array'
    return LiteralDeclaration.new(self.clone)
  end

  def write
    raise StandardError.new('No "write" method has been created for '+self.class.to_s) unless self.class.to_s == 'Array'
    line = '['    
    self.each do |x|
      line += x.write
      unless x.object_id == self.last.object_id then line += ', ' end
    end
    line += ']'
    return line    
  end

  def copy
    raise StandardError.new('No "copy" method has been created for '+self.class.to_s) unless self.class.to_s == 'Array'    
    result = []
    self.each {|x| result.push(x.copy) }
    return result
  end
  
  def to_literal
    return Literal.new(self.copy.collect {|x| x.to_literal})  
  end
  
  # This is a variation on the 'any?' except if the array contains an array
  # it continue the search into that array.
  # 
  # @param  &block    The block that evaluates if something exists in the array
  #
  # TODO  This method could probably be cleaned up a bit
  #
  def contains?(&block)
    self.each do |x|
      if x.respond_to?(:contains?) 
        if x.contains?(&block)
          return true
        end
      end
      return true if block.call(x)
    end
    return false
  end
  
  # Returns all the elements that match the selection criteria just 
  # like the select method.  However if it contains an array it
  # will seach the array as well.
  # 
  # @param  results       An array of current results that match the requirement
  #                       of the block.
  # @param  block         .
  #
  def select_all(results=[],&block)
    self.each do |x|
      if block.call(x)
        results.push(x)
      end
      if x.respond_to?(:select_all) 
        x.select_all(results,&block)  
      end
    end
    return results
  end  
  
  def to_intrinsic
    # TODO  SHould be all? not any?
    return IntrinsicTestCases.new if self.any? {|x| x.kind_of?(CTestCase)}  
    raise StandardError.new('Can not be converted to intrinsic instance '+self.class.to_s)
  end
  
end