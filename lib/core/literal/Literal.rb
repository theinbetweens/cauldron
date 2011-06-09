# The literal class represents a variable that doesn't reference
# a different variable.  For example 'any string' or 889.
#
# Scope - a literal strictly speaking doesn't need a scope id since
#         its scope will always be the root of the runtime method
#         therefore allowing it to be created anywhere.  
#
class Literal
  include Token
    
  attr_reader :value, :scope_id
  attr_writer :scope_id  
  
  def initialize(value)
    super()
    
    # Check the datatype of the literal
    case value.class.to_s
      when 'String'
      when 'Numeric'
      when 'NilClass'
      when 'Array'
      when 'Fixnum'
      when 'Symbol'
    else
      raise UnliteralisableError.new('Unknown literal data type: '+value.class.to_s)        
    end
    
    # Declare the accessable variable
    @value = value
  end
  
  def write()
    if @value.class.to_s == 'String' then return safe_quote(@value) end
    if @value.class.to_s == 'Symbol' then return @value.write end
    if @value.kind_of?(Array)  
      return @value.write
    end
    return @value.to_s
  end
  
  def describe
    return write
  end
  
  def copy
    return Literal.new(@value)
  end
  
  def copy_requirements
    return [Requirement.new(This.new,Equal.new,Literal.new(@value.clone))]
  end
  
  # Check whether this variable can use the specifed method
  # call.
  #
  def allowed? method_call
    return StatementCheck.new.valid_syntax?(self.write+'.'+method_call.write)
  end
  
  # Returns a statement that declares a literal
  #
  def declaration_statement
    return Statement.new(ClassMethodCallContainer.new(LiteralClass.new,New.new,@value))        
  end
  
  def creation
    return 'Literal.new('+@value.creation+')'
  end
  
  def to_literal_string
    return write
  end
  
  def to_declaration
    return LiteralDeclaration.new(@value)
  end
  
  def equivalent?(to)
    return false unless to.class == self.class
    if @value.kind_of?(Array)
      @value.zip(to.value) do |x,y|
        return false unless x.equivalent?(y)
      end
      return true
    else
      return true if @value == to.value
    end
    return false
  end
  
  # Returns an array of desctructive instance calls given the available
  # variables.
  # 
  # @param  available     An array of other variables that can be used as
  #                       parameters. 
  #
  def destructive_instance_calls(available=[])
    return []
  end  
  
protected   
  
  # NOTE: There is a bash command 'quote' that might be useful if this approach
  #       doesn't work out.
  #
  def safe_quote(string)
    return "'"+string+"'"
  end
  
end
