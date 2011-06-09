# TODO  I am duplicating variables here with array, index, subject and method_call
class ArrayAccess < InstanceCallContainer
  include VariableIncluded
  
  attr_reader :array, :index
  
  def initialize(array,index)
    @array = array    
    @index = index
    super(@array,'[Array Access]',index)
  end
  
  def write
    return @array.write+'['+@index.write+']'
  end
  
  def describe
    return @array.describe+'['+@index.describe+']'    
  end
  
  def response
    return eval(@array.literalise.write+'['+@index.write+']').to_var
  end
  
  def cauldron_method_calls
    return @array[@index].cauldron_method_calls
  end  
  
  def copy
    return ArrayAccess.new(@array.copy,@index.copy)
  end
  
  def variable
    return @array.copy
  end
  
  def closure
    return ['[',']']
  end     
  
  # Returns all the elements that match the selection criteria just 
  # like the select method.  However is this contains an array it
  # will seach the array.
  # 
  # @param  results       An array of current results that match the requirement
  #                       of the block.
  # @param  block         .
  #
  def select_all(results=[],&block)
     results.push(@array) if block.call(@array)
     results.push(@index) if block.call(@index)
     if @array.respond_to?(:select_all) 
       @array.select_all(results,&block)
     end
     if @index.respond_to?(:select_all)
       @index.select_all(results,&block)
     end
     return results
  end    
  
  # Returns true if the passed argument is the same kind of ArrayAccess - in
  # that it is the same class, array and index.
  #
  # @param  to      The array access that is being compared with this array access 
  #                 instance to determine if their equivalent.
  #
  def equivalent?(to)
    return false if to.class != self.class
    return false unless to.array.equivalent?(@array)
    #return false unless to.array == @array
    return false unless to.index.equivalent?(@index)
    #return false unless to.index == @index
    return true
  end      
  
  # Returns a string calling the specfied index. e.g. "[4]"
  # 
  def to_literal_string
    return write    
  end
  
  def replace_theory_variables!(mapping)
    if @array.kind_of?(TheoryVariable) && mapping.has_key?(@array.theory_variable_id)
      @array = mapping[@array.theory_variable_id].copy
    elsif @array.respond_to?(:replace_theory_variables!)
      @array.replace_theory_variables!(mapping)
    end  
    if @index.kind_of?(TheoryVariable) && mapping.has_key?(@index.theory_variable_id)
      @index = mapping[@index.theory_variable_id].copy
    elsif @index.respond_to?(:replace_theory_variables!)
      @index.replace_theory_variables!(mapping)
    end
    
  end  
  
end
