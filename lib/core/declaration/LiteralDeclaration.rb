# Literal declarations when written appear like.  'ssdkfj' or MethodUsage.new
# while VariableDeclarations when write appear like var_0 etc.
#
class LiteralDeclaration < Declaration
  attr_reader :value
  
  def initialize(val)
     
     #  Check that the value is valid
    case val.class.to_s
      when 'String'
      when 'Array'
      when 'Fixnum'
      when 'NilClass'      
    else
      raise StandardError.new('Unexpected literal declaration value '+val.class.to_s)
    end
     
      super(val)
  end
  
  def write
    return @value.write
  end
  
  def copy    
    unless @value.nil? then return LiteralDeclaration.new(@value.copy) end
    return LiteralDeclaration.new(nil)
  end
  
  # Returns the declaration as a string.  Essentially just writing the value since
  # these are literals.
  #
  def to_literal_string
    return write
  end

  # Compares the passed argument and returns true if the comparison is
  # the same class and same value.
  # 
  def equivalent?(to)
    return false if to.class != self.class
    return false unless to.value == @value
    return true
  end       
      
end