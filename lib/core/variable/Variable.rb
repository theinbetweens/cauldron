# This class represents any variable object used to help generate 
# a method.
#

module Variable 
  
  include VariableIncluded
  
  @@variable_id = 0
  
  # The unique id is used to identify actually different variables.  This essentially occurs 
  # when a destructive method call is used.  For example an two array variables might have the
  # same variable_id say '2' so would both be written as 'var_2' but one of them might have had
  # another element pushed into it e.g. 'var_2.push(6)'.  The changed variable would then 
  # receive a different uniq_id. 
  @@uniq_id = 0
  
  #CONST_TEST = 'test'
  # 331 Constants are in capitals and accesses Variable::CONST_TEST class variables use @@    
  
  # Create the declaration for a unique variable id.  The unique_variable_id reflects the different
  # values a variable might have.  For example if a variable is overwritten it will have the same
  # name as it's predisessor but not the same value.
  attr_reader :uniq_id, :scope_id
  attr_writer :scope_id
  
  def self.reset_global_id
    #http://www.zenspider.com/Languages/Ruby/QuickRef.html
    unless $".include?('test/unit.rb')
     StandardLogger.instance.log 'WARNING: Resetting variable id, this should only be done for tests'
    end
    @@variable_id = 0
    @@uniq_id = 0    
  end  
  
  def self.variable_id
    return @@variable_id
  end  
  
  # TODO  This is not a permenant method it is a temporary fix
  #       as I migrate away from requirements.
  #
  def meets_requirements? of    
    return true if of.literalise.value == self.value
    return false
  end
  
  # Change the value of the variables uniq_id
  #
  # @param  The new value for the variables uniq_id 
  #
  def uniq_id=(value)
    @uniq_id = value
    raise StandardError.new('Should be fixnum') unless value.kind_of?(Fixnum)
  end
  
  # Updates the uniq_id for this variable so it can be regarded
  # differently.  Uniq_ids are used in the CodeHandler to allow
  # the inclusion of the correct statements to recreate a variable.
  #
  def increament_uniq_id!
    @uniq_id = @@uniq_id    
    @@uniq_id += 1
  end
  
  def to_var(id=nil)
    raise StandardError.new(self.class.to_s+' is already a Variable - should not call to_var')  
  end
  
end