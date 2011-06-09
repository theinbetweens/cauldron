class MethodParameter < BaseVariable
  attr_reader :usage_variable
  
  # TODO  I'm trying to move away from requirements
  #
  # @param  *requirements   Any number of requirements that describe the 
  #                         the properties of the method variable.
  #                         For example self == 6
  def initialize(*requirements)
    super(nil)
  end
  
  # Returns true if this variables meets the requirements of the
  # supplied variable.  If the this meets the requirements of the
  # supplied variable then this variable could replace the 
  # supplied variable in a statement.
  #
  # TODO  Write tests for this
  # 
  # @param  of 
  #
  # TODO  Have an act_as call that doesn't return true/false but raises errors so I can identify
  #       why something can't be something else.
  #
  def meets_requirements? of
    
    # Handle the possible datatypes of "of"
    begin 
      if of.kind_of?(Variable)
        return meets_requirements_of_variable(of)
      elsif of.kind_of?(InstanceCallContainer)
        return meets_requirements_of_instance_call(of)
      else
        raise StandardError.new('Not expecting class of type '+of.class.to_s)
      end
    rescue FailedVariableMatch
      return false
    end
  end    
  
  # Raises an error to avoid me accidently trying to give this class the
  # method.
  #
  def to_literal_string
    # TODO  I should turn this on further down the line - it realtes to tracking
    #raise StandardError.new('Method Variables can\'t be converted to a literal string because they don\'t have a value')
    return self.write
  end
  
  #
  def describe(tab=0,context=self)
    
    # Create a temporay copy of the variable
    copied_var = self.copy

    unless context == self
      
      # Return a duplicate variable with the requirements in the context indicated
      copied_var = context.contextual_variable(copied_var.variable_id)
      
    end
    
    # Print the name of the variable
    line = ''    
    line += write
    
    # Print out each of the requirements
    copied_var.each do |x|  
      
      #tmp = gets      
      desc = x.describe(context)

      #tmp = gets
      desc.each_line do |l|
        line += "\t"+l
      end      
      line += "\n" unless x == copied_var.last      
    end
    line += "\n"
    
    return line
    
  end  

  def copy
    result = self.class.new(*self) {{:variable_id => self.variable_id,:uniq_id=>@uniq_id, :uniq_id_history=>@uniq_id_history.copy}}
    result.instance_variable = @instance_variable
    return result
  end  
  
  # Returns a reference to the usage variable that is represented 
  # by this variable.  Remember this MethodParameter represents 
  # a particular rule so its id doesn't reflect all cases.
  #
  def usage_variable
    return @usage_variable  
  end
  
  # Set the usage variable that this method variable should be used
  # as.  This is set when a method variable is added to a method.
  # 
  def usage_variable= usage
    @usage_variable = usage
  end
  
  # Attempts to return a literal that meets
  # all the requirements.
  #
  def literalise

    # Does the variable have any "equal to literal" requirements
    self.each do |req|
      if req.structure_match?([This,Equal,Literal])
        return req[2].copy
      end
    end
    
    raise StandardError.new('The literalise call is very basic right now and needs improved')
  end  
  
  # Returns a statement showing the variable being declaraced
  # 
  # MethodParameter.new(Requirement.new())
  # 
  def declaration_statement
    # TODO  Check that .copy method call works across all the uses of "declaration_statement"
    return Statement.new(ClassMethodCallContainer.new(MethodParameterClass.new,New.new,*self.collect {|x| x.copy.declaration_statement}))    
  end 
  
  def to_declaration
    return VariableDeclaration.new('MethodParameter',*self.collect {|x| x.to_declaration})
  end  
  
private 
  
  # TODO  Write tests for this
  def meets_requirements_of_variable(this)
    
    # Check if var has any requirements - if it doesn't have any then anything can be it
    return 'is' if this.empty?

    begin
      
      # Can this be literised? (it makes it easy to check requirements)
      if self.literalisable?
        
        # then change it into a literal value
        literal = self.literalise
        
        # Good stuff - next lets see if we can confirm the requirements of 'var'
        begin
          
          # Goes through all of var requirements and substitutes self for the literal
          this_could_be_that(literal,this)          
          return true          
        rescue IncompatiableRequirementsError => e
          StandardLogger.instance.info e
          return false
        end          
        
      else  # If self can't be literalised

        # Go through each of the supplied variables requirements
        all_requirements_matched = true
        this.each do |req|    
          requirement_matched = false
          self.each do |own_req|
            if own_req.write == req.write
              requirement_matched = true
              break
            end
          end
          all_requirements_matched = false unless requirement_matched
        end
        
        return true if all_requirements_matched
        return false
      
      end

    rescue StandardError => e
      StandardLogger.log e
      return false
    end        
    return false
      
  end
  
  # TODO Write tests for this
  def meets_requirements_of_instance_call(instance_call)
    #unless instance_call.literalisable?
    #  raise StandardError.new('Unable to litralise instance call '+instance_call.write)
    #end
    
    # Attempt to litralise the variable 
    # TODO  The variable class returns a Literal the InstanceCallContainer returns a 
    #       value.  They don't need to do different things.
    if(self.literalisable?)
      return self.literalise.value == instance_call.literalise
    else
      raise FailedVariableMatch.new('Unable to litralise variable to see if it meets requirements')
    end
    
  end  
  
end