class Object
  
  # This is a more useful 'public_methods' since it excludes 
  # the standard methods inheritated from the Object super
  # class.
  #
  #def uniq_public_methods
  #  obj = Object.new
  #  return self.public_methods - obj.public_methods
  #end
  
  # Use p406
  # Example.private_instance_methods(false)
  # Example.public_instance_methods(false)
  
  def instance_call_structures
    return []
  end
  
  def cauldron_method_calls
    return []
  end    
  
end