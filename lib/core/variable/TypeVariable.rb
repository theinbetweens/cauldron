# This variable doesn't represent a specific data type it is merely the parent
# of all the other typed variables e.g. FixnumVariable, StringVariable etc.
#
class TypeVariable < BaseVariable
  attr_reader :value
  
  def initialize(val,id=nil)
    @value = val
    super(id)
  end
  
  def copy
    copied = self.class.new(@value.copy) {{:variable_id => self.variable_id,:uniq_id=>@uniq_id, :uniq_id_history=>@uniq_id_history.copy}}
    copied.instance_variable = @instance_variable
    return copied
  end  
  
  # Only let this method be called from fellow Fixnum classes or Unknowns
  # NOTE  I have allowed variable ids to be set to allow runtime methods to change 
  #       the id of passed variables.  
  def variable_id=(id)
    # TODO  This would be nicer if it wasn't so hard coded ./lib/core/variable/Unknown.rb
#    unless caller.first.split(':')[0]==__FILE__ or caller.first.split(':')[0]=='./lib/core/variable/Unknown.rb'
#      raise StandardError.new('Illegal attempt to set variable_id')
#    end
    @variable_id = id
  end    
  
  def literalisable?
    return true
  end
  
  def literalise
    return Literal.new(@value.copy)
  end
  
  def realised?
    return true unless @value.nil?
    return false
  end
  
  def to_literal_string
    return @value.to_literal_string
  end    
  
  def describe(tab=0)
    l = ''
    tab.times {|x| l += "/t" }
    l += '['+self.class.to_s+'] '+@value.write
    l += "\n"
    return l
  end  
  
  
  def cauldron_method_calls
    return ['.value']
  end      
  
  # Compares the passed argument and returns true if it is a unknown 
  # variable which is treated as a wild card or a variable with
  # the same value.  
  # 
  # TODO  I'm not sure I like UnkownVariables being treated as wild cards
  #
  def equivalent?(to)
    return true if to.kind_of?(Unknown)
    return false if to.class != self.class
    return false unless to.value == @value
    return true
  end    
  
end