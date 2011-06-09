# TODO  I think this class might have been replaced with InstanceCallContainerStructure
class InstanceCallStructure < Array
  attr_reader :instance_class, :method_call
  
  #
  #  @param   instance_class  The class of the instance that should be called e.g. StringVariable
  #  @param   method_call     An instance of the method_call
  #  @param   parameters      The parameters that the instance method call excepts 
  # 
  def initialize(instance_class,method_call,*parameters)
    # TODO  What are the two parameters an array expects
    super()
    
    # Declare the elements that make up the instance call
    @instance_class = instance_class
    @method_call = method_call
    
    # Add the parameters to the array 
    parameters.each do |code|
      self.push(code)
    end    
  end
  
  #
  def instance_calls(available=[])
    
    # Create an array of potential instance calls
    potential_instance_calls = []
    
    # Find a variable thats class is @instance_class
    available.each do |avail|
      
      if avail.class == @instance_class
        
        # We have a possible instance class
        # TODO  Try with class and method call mismatch
        if self.length == 0
          potential_instance_calls.push(InstanceCallContainer.new(avail.copy,@method_call.copy))
          next
        end
        
        # Retrieve appropriate values for each of the intance calls parameters
        
        
      end
      
    end
    
    return potential_instance_calls
        
  end
  
end