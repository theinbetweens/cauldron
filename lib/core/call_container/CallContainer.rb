class CallContainer < Array
  include WriteParameters  
  
  attr_reader :parameters
  
  def initialize(subject,method_call,*parameters)
    
    # Check the type for the class name
    @subject = subject
    
    # Check the datatype of the method_call
    @method_call = method_call
    
    @parameters = parameters
    
    super()    
  end    
  
  def write(tab=0)
    return ("\t"*tab)+@subject.write+method_call.write+write_params(@parameters,method_call.closure)
  end  
  
  def describe(tab=0)
    return ("\t"*tab)+@subject.describe+method_call.write+describe_params(@parameters,method_call.closure)
  end    
  
  def has?(&block)
    @parameters.each do |x|
      return true if block.call(x)
    end
    return true if block.call(@subject)
    return true if block.call(@method_call)
    return false
  end  
  
  # [Overwrite - from Array] Returns any elements that match the supplied
  # criteria with this array as well as the subject.
  #
  def select_all(results=[],&block)
     results.push(@subject) if block.call(@subject)
     results.push(@method_call) if block.call(@method_call)
     if @subject.respond_to?(:select_all) 
       @subject.select_all(results,&block)
     end
     if @method_call.respond_to?(:select_all)
       @method_call.select_all(results,&block)
     end
     @parameters.select_all(results,&block)
     return results
  end

  def replace_theory_variables!(mapping)
    @parameters.each_with_index do |x,i|
      if x.kind_of?(TheoryVariable) && mapping.has_key?(x.theory_variable_id)
        @parameters[i] = mapping[x.theory_variable_id].copy
      end
    end
    if @subject.kind_of?(TheoryVariable) && mapping.has_key?(@subject.theory_variable_id)
      @subject = mapping[@subject.theory_variable_id].copy
    end
    if @method_call.kind_of?(TheoryVariable) && mapping.has_key?(@method_call.theory_variable_id)
      @method_call = mapping[@method_call.theory_variable_id].copy
    end    
  end        
  
end  