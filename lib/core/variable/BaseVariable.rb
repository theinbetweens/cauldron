#require "set"
# This was introduced so I could maintain the use of the class variable
# @@variable_id with the ArrayVarialble without having to include 
# requirements with the array.  
#
class BaseVariable < Array
  attr_reader :variable_id , :instance_variable, :value, :uniq_id_history
  attr_writer :instance_variable, :uniq_id_history
  
  include Variable
  include Token
  # TODO  VariableIncluded is in Variable so i can probably get rid of the VariableIncluded
  #include VariableIncluded
  
  # TODO  I think I'll get rid of the id parameter and just use blocks
  # 
  #  NOTE:  You can set the variable ids by passing it in a block
  #         e.g. BaseVariable.new {[8,9]}
  #         where 8 is the variable_id and unique_id is 9
  #
  def initialize(id=nil)  
    super()
    
    # TODO  I should maybe include a check on all .copy methods to ensure a block is provided
    # Set the variable id for the newly created variable    
    if block_given?
      # TEMP
      if yield.kind_of?(Fixnum)
        raise StandardError.new('Expecting array')
      end
      unless yield[:variable_id].nil?      
        @variable_id = yield[:variable_id]      
      else
        @variable_id = @@variable_id
        @@variable_id += 1
        # TODO  Should have a separate call that returns @@variable_id and increaments @@variable_id
      end
      unless yield[:uniq_id].nil? 
        raise StandardError.new('Expecting Fixnum') unless yield[:uniq_id].kind_of?(Fixnum)
        @uniq_id = yield[:uniq_id]
      else  
        @uniq_id = @@uniq_id
        @@uniq_id += 1
      end
      
      @uniq_id_history = yield[:uniq_id_history] unless yield[:uniq_id_history].nil? 
      
    else
      if id.nil?
        @variable_id = @@variable_id
        @@variable_id += 1      
      else
        @variable_id = id
      end
      
    end
    
    # Give the variable an unique id
    if @uniq_id.nil?
      @uniq_id = @@uniq_id 
      #raise StandardError.new('Uniq id change point') if (@uniq_id+1) == 86
      @@uniq_id += 1      
    end
    
    @uniq_id_history ||= []
    
    # Flag indicating if this is a scope variable or a instance variable
    @instance_variable = false
    
  end
  
  def self.reset_global_id
    #http://www.zenspider.com/Languages/Ruby/QuickRef.html
    unless $".include?('test/unit.rb')
      StandardLogger.log 'WARNING: Resetting variable id, this should only be done for tests'
    end
    @@variable_id = 0
  end
  
  # Returns the variable if the ids matched
  #
  # @param  id    The uniq_id of the variable that is being looked for
  #
  def find_actual_variable(uniq_id)
    return self if @uniq_id == uniq_id
    throw :variable_not_found
  end  
  
  # Returns an array of instance calls that can be created from
  # this variable.
  #
  # NOTE: I checked that instance_calls wasn't a intrinsic method.
  # 
  # TODO  Test this (esp with ArrayVariable)
  #
  def instance_calls(with=[])
    return [] unless self.realised? 

    # Attempt to retrieve the literal value for the variable
    #val = self.literalise.value
    val = self.value
    
    # TODO  I suspect this method is redundant since it is always overwritten
    
    # Now retrieve all the possible instance call structures for that value
    results = []
    val.instance_call_structures.each do |struct|

      if struct.instance_class != self.class then raise StandardError.new('Unexpected class type: - expecting '+val.class.to_s+' but was '+struct.instance_class.to_s) end
      
      # Now create a method call of the instance call
      inst_call = InstanceCallContainer.new(self.copy,struct.method_call.copy) 
      results.push inst_call

    end
    return results    
  end
  
  # Returns an array of instances calls that return a value and are 
  # therefore approriate for declaration statements. 
  #
  def returning_instance_calls(available=[])
    return instance_calls(available)  
  end    
  
  def destructive_instance_calls(with=[])
    raise StandardError.new(" 'destructive_instance_calls' method should be overridden for "+self.class.to_s)
  end
  
  #
  # 
  #
  def write()
    if (@instance_variable)
      return '@var_'+variable_id.to_s    
    end
    return 'var_'+variable_id.to_s    
  end  
  
  def write_with_uniq_id
    if (@instance_variable)
      return '@var_'+variable_id.to_s+'_u'+uniq_id.to_s    
    end
    return 'var_'+variable_id.to_s+'_u'+uniq_id.to_s            
  end
  
  # Always returns true since realised variables should extend this class
  # but overwrite this method.
  #
  def realised? 
    return false  
  end
  
end