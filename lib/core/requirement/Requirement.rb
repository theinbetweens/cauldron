# A requirement is simply a statment that evaluates to true.
# 
# For example this == 7
class Requirement < Array
  include PrintVariables
  
  attr_reader :parent  
  attr_writer :parent
  
  alias :array_push :push
  
  def initialize(*parameters)
    super()
    parameters.each do |param|
      self.push param
    end
  end
  
  # Compares another requirement to its self and to determine
  # whether they are mutually exclusive.
  #
  # For example:
  #     self > 8 ~= requirement < 7
  #
  def mutually_exclusive?(requirement)
    return false
  end
  
  def describe(context=self)
    
    line = ''        
        
    # Handle describing requirement 
    if context == self
      self.each do |code|   
        line += code.write
      end
      line += "\n"
      return line
    end
    
    # Handle the description for a higher context
    after_equal_sign = false
    self.each do |code|
      next if code.kind_of? This 
      
      if code.kind_of? Equivalent
        after_equal_sign = true
        line += "\t" 
      end
      
      # Handle instance calls (should be shown as .class = String
      if code.kind_of? InstanceCallContainer
        if after_equal_sign
          line += code.write
        else
          line += '.'+code.method_call.write
        end
      else
        line += code.write
      end
      
      line += ' ' unless code == self.last
    end
    return line
    
  end
  
  # Returns true if the requirement contains any other variables
  # e.g.  self.chop = 'test' returns false
  #       self.length = var4 returns true
  # 
  def any_variables?
    self.each do |code|
      if code.kind_of? InstanceCallContainer 
        return true if code.subject.kind_of? Variable
      end
      return true if code.kind_of? Variable
    end
    return false
  end
  
  # Writes out the nature of the requirement.  
  #
  # @param  context   The context in when the requirement is being written.  This
  #                   should be something that can print variables.
  # @param  variable  The variable that represent 'self' in the requirement.  Otherwise
  #                   it defaults to 'self'
  # 
  def write(context=self,variable=nil)

    #variable = parent unless parent.nil?
    
    line = ''
    self.each do |x|
      #if x.kind_of? This or x.kind_of? InstanceCallContainer
    if x.kind_of? This or x.kind_of? InstanceCallContainer      
        line += x.write+' '
      else
        line += x.write+' '
      end
    end
    return line
  end
  
  # Intended to be a more reliable clone.  So will go deeper
  # into the object.
  #
  def copy
    copied_requirement = Requirement.new
    self.each do |code|
      copied_requirement.push code.copy
    end
    copied_requirement.parent = nil
    return copied_requirement
  end
  
  # Returns true if the requirement contains a 'self'.  I don't think
  # it's possible or desirable not to so I'll probably end up dropping 
  # this method.
  #
  def contains_self?
    self.each do |x|   
      if x.kind_of? This then return true end
      
      # Check any instance calls for 'self'
      if x.kind_of? InstanceCallContainer
        return true
      end
      
    end
    return false
  end
  
  # Changes the "self" value for a literal value to determine
  # whether the literal value could be used in place.  For
  # example:
  #
  # self.chop = 8 -> subst self for 22                [WRONG]
  # self.chop = 8 -> subst self for 'community'       [CORRECT]
  # 
  def subst_self_for literal
    
    # Make a copy of the current requirement
    copied_requirement = self.copy
    copied_requirement.each_with_index do |x,i|
      if x.kind_of? InstanceCallContainer
        x.subst_self_for literal
      end
      if x.kind_of? This
        copied_requirement[i] = literal
      end
    end    
    
    return copied_requirement
    
  end
    
  # Pretty much the same as each except that it includes 
  # instance calls as two elements e.g. the suject and 
  # the method call.
  #  
  def each_bit
    self.each do |g|
      if g.kind_of? InstanceCallContainer
        yield g.subject
        yield g.method_call        
        next
      end
      yield g
    end
  end
  
  # Checks whether the structure of the requirement 
  # matches that supplied.
  # 
  # @param  structure   A structure is simply an array of 
  #                     classes e.g. [This,Equal,Literal]
  #
  def structure_match?(structure)

    # Checks that they are at least the same length
    if self.length != structure.length then return false end
    
    structure.each_with_index do |x,i|
      return false unless self[i].kind_of?(x)
    end
    return true
  end
  
  # Evaluates the code in the requirement to determine 
  # whether it generates a runtime error.
  #
  def evaluate
    evaluation_code = ''  
    self.each do |x|
      
      # Change the equal sign to equivalent for evaluation purposes
      if x.kind_of? Equal
        evaluation_code += ' == '
        next
      end
      evaluation_code += x.write(self)
    end
    eval 'return '+evaluation_code
  end
  
  def valid?
    begin
      return evaluate  
    rescue NoMethodError => e
      StandardLogger.log e
      return false
    rescue RuntimeError => e
      StandardLogger.log e
      return false
    end  
  end
  
  # Evaluates the literal by replacing 'self' with the 
  # literal value provided.
  # 
  def use?(literal)
    
    new_requirement = subst_self_for literal

    # Change any equal(=) to equivalent(==)
    new_requirement_string = 'if '
    new_requirement.each do |code|

      if code.kind_of? Equal
        new_requirement_string += ' == '  
        next
      end

      new_requirement_string += code.write
    end
    
    new_requirement_string += ' then return true end'+"\n"+'return false'
    
    # See if the evaluated requirement breaks anything
    begin
      eval new_requirement_string
    rescue StandardError => e
      StandardLogger.log e
      return false
    end
    return true
    
  end
  
  # Returns a string of the requirement but also includes the variable
  # id for any variables.
  #
  def write_with_variable_id(tab=0,context=self)
    line = ''
    tab.times {line += "\t" }    
    self.each do |x|
      if x.kind_of? Variable
        line += x.write(self)+'('+x.variable_id.to_s+') '  
        next
      end
      if x.kind_of? InstanceCallContainer
        line += x.write(self)+'('+x.subject.variable_id.to_s+')'
        next
      end
      line += x.write(self)
    end
    return line    
  end
  
  # Returns a statement containing a MethodClass instance 
  # which is basicall Requirement.new(This.new,Equal.new,Something else)
  #
  def declaration_statement
    
    # Create the class method call 
    instance_declaraction = ClassMethodCallContainer.new(RequirementClass.new,New.new,*self.collect{|x|x.copy.declaration_statement})  
    
    s = Statement.new(instance_declaraction)
    return s
      
  end
  
protected
  
  def push(val)
    array_push(val)
  end
  
end