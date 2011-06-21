# This class represents any instance method call.  For example:
#
# 'test'.length
# foo.class
# bar.nil?
#
# TODO  The InstanceCallContainer should may be be replaced with just statement - the parser
#       just has :call types.
#
class InstanceCallContainer < CallContainer
  include PrintVariables
  include VariableIncluded
  
  attr_reader :subject, :method_call
  attr_reader :value

  # 
  # @param  subject       The variable or literal that is being acted upon
  # @param  method_call   The method call being made against the variable 
  #                       or literal
  #  
  def initialize(subject,method_call,*params)
    raise StandardError.new('Use ClassMethodCallContainer here') if subject.kind_of?(ClassName)
    super(subject,method_call,*params)        
  end
  
  def write_with_uniq_id
    if @subject.respond_to?('write_with_uniq_id')
      return @subject.write_with_uniq_id+'.'+method_call.write+write_params(@parameters)
    end
    return @subject.write+'.'+method_call.write+write_params(@parameters)
  end
  
  # TODO  There are many similar version of this method used
  def replace_theory_variables!(mapping)
    if @subject.kind_of?(TheoryVariable) && mapping.has_key?(@subject.theory_variable_id)
      @subject = mapping[@subject.theory_variable_id].copy
    elsif @subject.respond_to?(:replace_theory_variables!)
      @subject.replace_theory_variables!(mapping)
    end
    @parameters.each_with_index do |x,i|
      if x.kind_of?(TheoryVariable) && mapping.has_key?(x.theory_variable_id)
        @parameters[i] = mapping[x.theory_variable_id].copy
        next
      end
      @parameters[i].replace_theory_variables!(mapping) if @parameters[i].respond_to?(:replace_theory_variables!)
    end

  end

  # TODO  This can probably replace replace_theory_variables!
  def replace_variables!(mapping)
    if @subject.kind_of?(Variable) && mapping.has_key?(@subject.variable_id)
      @subject = mapping[@subject.variable_id].copy
    elsif @subject.respond_to?(:replace_variables!)
      @subject.replace_variables!(mapping)
    end
    @parameters.each_with_index do |x,i|
      if x.kind_of?(Variable) && mapping.has_key?(x.variable_id)
        @parameters[i] = mapping[x.variable_id].copy
        next
      end
      @parameters[i].replace_variables!(mapping) if @parameters[i].respond_to?(:replace_variables!)
    end

  end  
  
  # Returns a duplicate instance call container with any matching
  # variables replaced with the variable supplied.
  #
  # @param  var     The variable that will replace any matching variables
  #
  def replace_variable_if(var,&block)
    container = self.copy.clear   
    if block.call(@subject)    
      container.subject = var if block.call(@subject)
    end
    @parameters.each do |x|
      if x.kind_of?(Variable)
        container.push(var) if block.call(x)  
      end
      container.push(x.copy)           
    end
    return container
  end
  
  def contains?(&block)
    return true if @parameters.contains?(&block)
    return true if block.call(@subject)  
    return true if block.call(@method_call)      
    return false
  end
  
  def write_in_context(context=self)  
    return @subject.write_in_context(context)+'.'+method_call.write
  end
  
  def copy
    copied_subject = @subject.copy
    return InstanceCallContainer.new(copied_subject,@method_call.copy,*@parameters.collect {|x| x.copy})
  end
  
  def variable
    return @subject
  end
  
  def literalisable?
    return @subject.literalisable?
  end
  
  # Attempts to return a literal value for the result of calling
  # this instance call.
  #
  def literalise(context=self)
    unless(@subject.literalisable?)
      raise FailedToLiteraliseError.new('Failed to literalise '+self.write+' couln\'t literalise '+@subject.write)
    end 
    return eval(@subject.literalise.write(context)+@method_call.write)
  end
  
  def value
    return literalise
  end
  
  # Returns the actual variable with the specified id. 
  # 
  # @param  id  
  #
  def find_actual_variable(id)
    return @subject if @subject.uniq_id == id
    @parameters.each do |x|
      return x if x.uniq_id == id
    end
    throw :variable_not_found
  end  
  
  def response
    case value.class.to_s
      when 'string'.class.to_s
        return StringVariable.new(value)
        break
      when 8.class.to_s
        return FixnumVariable.new(value)
    else
      raise StandardError.new('Unknown class '+value.class.to_s)
    end
  end
  
  # Set the value of the container for the subject
  #
  def container=(val)
    @container = val
    @subject.container = @container
  end
  
  # Determines whether the is an imediate 'self' in the instance
  # call.
  def contains_self?
    return true if subject.kind_of? This
    return false
  end
  
  # Substitutes one variable for another one providing the 
  # the block returns true.
  # 
  def subst!(var,&block)
    @subject = var.copy if block.call(@subject)
    @parameters.each_with_index do |x,i|
      if block.call(x)
        @parameters[i] = var.copy
      end
    end
    return self
  end
  
  # Substitutes the 'self' in the instance call for a literal
  # value and evaluates it.
  #
  def subst_self_for literal
    if subject.kind_of? This
      @subject = literal
    end
  end
  
  def subject=(val)
    @subject = val
  end
  
  def variable_id
    return @subject.variable_id
  end
  
  def find_variable(id)
    raise StandardError.new('This instance call does not contain the variable with the id '+id.to_s) unless variable_id == id
    return contextual_subject
  end
  
  # 
  def copy_contextual_variable
    return contextual_subject  
  end
  
  def declaration_statement
    new_instance_call = ClassMethodCallContainer.new(InstanceCallContainerClass.new,New.new,@subject.copy.declaration_statement,@method_call.copy.declaration_statement)    
    return Statement.new(new_instance_call)
  end
  
  # This method is used during tracking to print a general description of what
  # the instance call is doing. e.g. 'test'.chop.
  #
  def to_literal_string
    return @subject.to_literal_string+'.'+@method_call.to_literal_string
  end
  
  # Returns a declaration instance that will create a InstanceCallContainer with 
  # same properies as this InstanceCallContainer.
  #
  def to_declaration
    return VariableDeclaration.new('InstanceCallContainer',*[@subject.to_declaration,@method_call.to_declaration,*@parameters.collect {|x| x.to_declaration}])  
  end
  
  # Returns an array of all the variables used in this instance call.
  #
  def variables
    if @subject.kind_of?(Variable) 
      results = [@subject.copy]
    end
    results ||= []
    @parameters.each do |x|
      results.push(x.copy)
    end
    return results
  end
  
  # Returns true if the supplied argument is equivant to this instance call 
  # container.  They are equivalent if the their classes are the same, their
  # subjects are equivalent, their method_calls are the same and use equivalent
  # arguments.
  #
  def equivalent?(to)
    return false unless self.class == to.class
    return false unless self.length == to.length
    return false unless @subject.equivalent?(to.subject)
    return false unless @method_call.class == to.method_call.class
    return false if @parameters.length != to.parameters.length
    @parameters.each_with_index do |x,i|
      return false unless x.equivalent?(to.parameters[i])
    end
    return true
  end
  
  def replace_variables_alt!(map)
    if @subject.kind_of?(TheoryVariable)
      map.each do |key,value|
        if @subject.theory_variable_id == key.theory_variable_id
          @subject = value
          break
        end
      end
    elsif(@subject.kind_of?(StringLengthClass))
    else
      @subject.replace_variables_alt!(map)
    end
    
    @parameters.each_with_index do |x,i|
      if x.kind_of?(TheoryVariable)
        map.each do |key,value|
          if x == key
            @parameters[i] = value
          end
        end
      else
        @parameters.replace_variables_alt!(map)
      end
    end
  end
    
protected

  def contextual_subject
    
    # Check that the literal supports the method call
    if @subject.kind_of? Literal
      raise NameError.new('Literal '+self.write+' does not have the method call '+@method_call.write) unless @subject.allowed? @method_call  
    end
    
    # Copy the subject variable
    copied_subject = @subject.copy
    
    # Retrieve any requirements associated with the method call
    # @method_call.requirements do |req|
      # copied_subject.push(req)
    # end
    return copied_subject
    
  end
  
end