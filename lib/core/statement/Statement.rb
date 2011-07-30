class Statement
  include PrintVariables
  include ActsAsStatement
  include ActsAsCode
  
  attr_reader :statement_id, :scope, :statement_level, :statement_id
  # TODO  scope and statement level are confusing - not sure of the difference (I think it's legacy)
  attr_writer :scope, :statement_level, :overrides, :statement_id

  @@statement_id = 0
  
  #
  # @params     parameters      Any number of elements to make up the statement possible classes
  #                             include Equal, Addition, Unknown, StringVariable, Literal e.t.c
  # &block      [OPTIONAL]      A block can also be provided to preview the statement from being 
  #                             reviewed and therefore preventing changes to variables uniq_id.  
  #
  def initialize(*parameters)
    super()
    
    # 
    @overrides = nil
    @confirmed = false
    
    # Sets the flag that indicates the structure of the statement
    @structure = nil
    
    @nodes = []
    
    # Add the parameters to the array 
    parameters.each do |code|
      @nodes.push(code.copy)
    end
    
    # TODO  I might change the statement_id to be determined by the structure
    #       of the statement.
    @statement_id = @@statement_id
    @@statement_id += 1
    
    # Review completed statement
    if block_given?
      values = yield
      review if (values[:review])
    else
      review
    end      
    
  end

  # Resets the globablly used value for statements id
  #
  def self.reset_global_id
    #http://www.zenspider.com/Languages/Ruby/QuickRef.html
    unless $".include?('test/unit.rb')
      StandardLogger.log 'WARNING: Resetting variable id, this should only be done for tests'
    end
    @@statement_id = 0
  end  
  
  # If this statement declares a variable determine whether the
  # the variable has been previously declared.  If so mark this
  # statement as an "overrides" statement otherwise flag it 
  # as not.
  #
  def identify_overriding_statements(already_declared=[])
    [BaseVariable,Equal].zip(@nodes) do |x,y|
      return unless y.kind_of?(x)
    end
    already_declared.each do |x|
      if x[:variable_id] == declared_variable_id
        @overrides = true
        return
      end
    end
    already_declared.push({:variable_id => declared_variable_id})
    @overrides = false
  end

  # Returns this statement if it has the correct id
  #
  # @param  id    The id of the statement should exist 
  #
  def find_statement(id)
    if self.statement_id == id
      return self
    end
    raise FailedToFindStatementError.new('Couldn\'t find statement with id '+id.to_s)
  end    
  
  # Returns true if the statement overrides an existing variable.
  # So if a = 6 but a was already set to 4 then this would be 
  # an overriding statement.
  # 
  def overrides?
    return @overrides    
  end
  
  # Returns an array of variables in this statement
  #
  def variables
    return self.select_all([]){|x| x.kind_of?(Variable)}
  end
  
  # Returns an array of all the tokens in the statement.  A token
  # is any literal, variable, intrinsic runtime or intrinsic testcase
  #
  def tokens
    return self.select_all([]){|x| x.kind_of?(Token)}
  end
  
  #
  def each_variable
    variables.each { |x| yield x }
  end
    
  # Attempt to convert the statement into a string without any references
  # to variables where possible.  So varA = varB.chop might become 
  # "varA = 'test'chop"
  #
  def literalise

    # Go through each element in the statement and attempt to literalise it
    line = ''
    self.each do |code|
      unless code.kind_of? Variable or code.kind_of? InstanceCallContainer
        line += code.write
        next
      end
      if code.kind_of?(Variable)
        if code.literalisable?
          literal = code.literalise
          line += literal.write
          next
        end
        line += code.write
      elsif code.kind_of?(InstanceCallContainer)
        if(code.subject.literalisable?)
          literal = code.subject.literalise
          line += literal.write+'.'+code.method_call.write
          next
        end
        line += code.write
      end
    end
    return line  
  end
  
  # TODO  Maybe use a opject to handle the output of the statement.
  def write(tab=0)

    # Check the file type of tab
    raise StandardError.new('Unexpexted class "'+tab.class.to_s+'" for Fixnum (number of tabs)') unless tab.kind_of? Fixnum

    line = ''
    tab.times {line += "\t" }
    self.each do |code|
      line += code.write
      break if code.object_id == self.last.object_id
    end
    return line
  end
  
  def describe(tab=0)
    # Check the file type of tab
    raise StandardError.new('Unexpexted class "'+tab.class.to_s+'" for Fixnum (number of tabs)') unless tab.kind_of? Fixnum

    line = ''
    tab.times {line += "\t" }
    self.each do |code|
      line += code.describe
      break if code.object_id == self.last.object_id
    end
    return line  
  end  
  
  def write_with_uniq_id(tab=0)
    # Check the file type of tab
    raise StandardError.new('Unexpexted class "'+tab.class.to_s+'" for Fixnum (number of tabs)') unless tab.kind_of? Fixnum

    line = ''
    tab.times {line += "\t" }
    self.each do |code|
      # TODO  Doesn't need a space on the last code element
      #line += code.write_with_uniq_id+' '
      if code.respond_to?('write_with_uniq_id')
        line += code.write_with_uniq_id+' '
        next
      end
      line += code.write+' '
    end
    return line    
  end
  
  # NOTE  This method should only be used on realised statements
  def write_with_value(tab=0)
    
    # Check the file type of tab
    raise StandardError.new('Unexpexted class "'+tab.class.to_s+'" for Fixnum (number of tabs)') unless tab.kind_of? Fixnum

    line = ''
    tab.times {line += "\t" }
    self.each do |code|

      if code.kind_of?(Variable)

        line += code.write+'('+code.value.write+')'
        # unless code == self.last
          # line += ' '
        # end
        next
      end

      line += code.write
      
    end
    return line    
    
  end
  
  # Returns a string containing the written version of the statement 
  # but any variables will have there id in brackets after them.
  #
  # TODO  This method is duplicated with requirements
  #
  def write_with_variable_id(tab=0,context=self)

    line = ''
    tab.times {line += "\t" }    
    self.each do |x|
      if x.kind_of? Variable
        line += x.write+'('+x.variable_id.to_s+') '  
        next
      end
      if x.kind_of? InstanceCallContainer
        line += x.write+'('+x.subject.variable_id.to_s+')'
        next
      end
      line += x.write
    end
    return line
    
  end
  
  
  # Creates a copy of the statement.  The copy's variables should have
  # the same variable ids but should be different instances.  When 
  # all the code elements are added the statement is ascessed and the
  # the requirements updated approriately.
  #
  def copy
#    tmp = self.collect{|x| x.copy}
#    result = self.class.new(*tmp) {{:review=>false}}
#    result.statement_level = statement_level
#    return result
    return Marshal.load(Marshal.dump(self))
  end
  
  # Returns true if the statement contains any calls to a runtime
  # method.
  #
  def contains_method_call?
    return self.any? {|x| x.kind_of?(DefCall)}       
  end
    
  # Adds the new piece of code to the statement and update
  # the variables requirements to accomodate any change.
  #
  def push(code)
    
    # Add the new piece of code to the statement
    #array_push(code)
    @nodes << code   
    
    # Update the requirements to reflect the change
    update
    
  end
  
  def add(element)
    push(element)
  end
  
  def select_all(results=[],&block)
    return @nodes.select_all(results,&block)
  end
  
  def each
    @nodes.each {|x| yield x}
  end
  
  def last
    return @nodes.last
  end
  
  def each_with_index
    @nodes.each_with_index do |x,i|
      yield x, i
    end  
  end
  
  def []=(index,value)
    @nodes[index] = value
  end
  
  def [](index)
    return @nodes[index]
  end  
  
  def length
    return @nodes.length
  end
  
  def select_all(results=[],&block)
    return @nodes.select_all(results,&block)
  end
  
  def first
    @nodes.first
  end
  
  def clear
    @nodes.clear
  end
  
  # Indicates whether the statement is one that assigns
  # a value to another.  Essential "Does the statement
  # contain an equals sign?"
  #
  def assignment?
    if detect_class(Equivalent).nil? 
      return false
    end
    return true
  end
  
  #
  def right_hand_side
    l, r = self.split(Equivalent)  
    return r
  end
  
  def left_hand_side
    l, r = self.split(Equivalent)  
    return l
  end

  # Indicates whether the statement has been confirmed.   
  #
  def confirmed?
    return @confirmed
  end    
  
  # This writes and evalutes the syntax of a statement to
  # determine whether it can be used by it self.  
  # 
  # So something like var1 = var0.chop would fail since
  # var0 doesn't exist.  It needs to write to a different
  # class to avoid the situation where the statement
  # 'return false' would perceived as invalid syntax.
  # 
  def valid_syntax?
    return StatementCheck.new.valid_syntax?(self.write)
  end
  
  # yeilds each variable that is not declared in the statement and 
  # isn't known e.g. cat be literalised in the statement.
  #  
  def each_untyped_variable
    untyped_variables.each do |x|  
      yield x
    end
  end
  
  # Returns an array of all the untyped variables in the statement.
  # Excluding any declared variables in the statement.
  #
  def untyped_variables
    x = []
    not_declared_variables.each do |y|  
      x.push(y) unless y.kind_of?(TypeVariable)
    end
    return x
  end
  
  # Returns each of the variables that aren't realised.  In that 
  # they aren't TypeVariables and don't have a literal value.
  #
  def unrealised_variables
    results = []  
    variables.each do |x|
      unless x.kind_of?(TypeVariable) 
        results.push(x) 
        next
      end
      if x.value.nil? and !x.kind_of?(NilVariable)
        results.push(x)
      end
    end
    return results
  end
  
  # Displays each of the unrealised variables within the statement
  #
  def each_unrealised_variable
    unrealised_variables.each do |x|
      yield x
    end
  end  
  
  # Returns an array of all the undeclared variables in the
  # statement.  An undeclared variable is simply a 
  # variable not declared in the statement but used in it.
  # e.g. var_c = var_a+var_b var_a and var_b are the undeclared
  # variable.
  #
  def not_declared_variables()

    # The statement shouldn't be valid if there are undeclared variables
    return [] if valid_syntax?
    
    # Find any excluded variables(ones that are delcared within the statement)
    # e.g. var = 'test'.chop
    declared_variables = []
    if( (self[0].kind_of? Variable)&&(self[1].class == Equal) )  
      declared_variables.push(self[0].copy)
    end

    # Attempt to find all the undeclared variables
    undeclared = []
    variables.each do |x|
      next if declared_variables.any? {|y| y.uniq_id == x.uniq_id}
      undeclared.push(x.copy)
    end
    return undeclared
    
  end
  
  # TODO  It would be nicer to a subst that allows a block passed though
  #       e.g. a.subst(sub) {|x| x.variable_id == 9}
  #
  # Returns a new statement that is a duplicate of this statement
  # but with the specified variable replaced.
  # 
  # TODO  Use the name nest for more than one statement
  # TODO  Write allot!! of tests for this
  #
  # @param  id    The id of the variable that will be replaced from the statement
  # 
  def subst(id,var,context=self)    
    return self.copy.subst!(var){|x| x.uniq_id == id}
  end
  
  def subst!(var,&block)
    
    # TODO  I should probably check whether anything was substituted or or not              
    self.each_with_index do |x,i|
      next unless x.kind_of?(Variable) or x.kind_of?(InstanceCallContainer)    
      
      # Essentially checks whether element is an InstanceCallContainer
      if x.respond_to?(:subst!)
        self[i] = x.subst!(var,&block)
        next
      end   
      
      if block.call(x)
        self[i] = var.copy
      end
    end    
    return self
  end
  
  # TODO  I should have a realised statement class
  
  # # Finds each element that satisfy the 
  # # 
  # # @param  var   The variable to replace any elements that match the block.
  # #
  # def replace_variable_if(var,&block)
    # container = []
    # @nodes.each do |x|
      # if x.kind_of?(Variable)
        # if block.call(x)
          # container.push(var)
          # next          
        # end
      # end
      # if x.kind_of?(InstanceCallContainer)
        # container.push(x.replace_variable_if(var,&block))
        # next
      # end
      # container.push(x.copy)
    # end
    # #return self.copy(*container)
    # copied = self.copy().clear
    # container.each {|x| copied.push(x) }
    # return copied
#       
  # end
  
  # Returns a variable instance with the contextual requirements for the statement.
  # TODO  Don't really need these contextual_variable calls 
  #
  def context_variable(id)
    return find_variable(id)
  end

  def contextual_variable(id)
    return context_variable(id)
  end
  
  # Returns the variable or instance call that contains
  # the variable with the specidied id.  It doesn't search 
  # the requirements.
  #
  # @param  id    The id of the variable that should be returned
  #
  # TODO  Write test to retrieve declarared variable in a statement with two variables
  #       e.g. varA = varB-varC
  # 
  def find_variable(id)
    results = variables.select() {|x| x.variable_id == id}
    if results.empty?
      raise FailedToFindVariableError.new('Couldn\'t find variable with id = '+id.to_s+' in "'+self.write+'"')
    end
    return results.first
  end        
  
  # Returns the variable in this statement with uniq_id specified.  In
  # the event the variable resides in a instance call then that is
  # returned.
  #
  def find_actual_variable(uniq_id)
    target = self.variables.select {|x| x.uniq_id == uniq_id}
    return target[0] unless target.empty?
    raise FailedToFindVariableError.new('Couldn\'t find a variable with the id '+uniq_id.to_s+' in "'+self.write+'"')    
  end

  def replace_variable!(id,var)

    # Find the variable to be replaced
    target = self.find_actual_variable(id)  
 
    #raise StandardError.new('Both target and variable should be the same class('+target.class.to_s+' != '+var.class.to_s+')') unless(target.kind_of?(var.class))
    # TODO  Should check for two variable kinds to two instance call kinds
    self.each_with_index do |code,i|

      # TODO Need to test with changing instance calls
      next unless code.kind_of?(Variable) or code.kind_of?(InstanceCallContainer)

      if(code.variable_id==target.variable_id)
        
        if code.kind_of?(Variable)
          self[i] = var
        elsif code.kind_of?(InstanceCallContainer)
          self[i].subject = var
        end
        return self
      end
    end
    
  end     
  
  # TODO  Not sure whether both replace_variable! and subst_variable! are both needed  - either ways
  #       their names aren't descriptive enough to distinguish that one uses the uniq_id and one uses
  #       the variable.   
  #
  def subst_variable!(id,var)
    # => TODO Use replace_variable_if?
    self.each_with_index do |token,i|
      if token.kind_of?(Variable) && id == token.variable_id
        self[i] = var
        next
      end
      if token.kind_of?(Container)
        self[i] = token.subst_variable!(id,var)
      end
    end
    self
  end
  
  # Returns the id of the variable declared in this statement
  #
  def declared_variable_id
    raise UnexpectedStatementTypeError.new('Should be declaration statement type '+self.write) unless decalares_variable?
    return self[0].variable_id 
  end
  
  # Retuns an array of all the variable ids required for the
  # statement.  
  #
  def required_variable_ids
    results = self.variables.collect {|x| x.variable_id}
    return (results-[declared_variable_id])
  end
  
  # Returns true if the statement is simple.  In that it just re-declares
  # an existing variable e.g. var_a = var_b.
  #
  def is_simple?
    return false unless decalares_variable?
    # TODO  Look at what you call the right hand side of the equation
    if right_hand_side.length == 1 && right_hand_side[0].kind_of?(Variable)
      return true
    end
    return false
  end
  
  # TODO  Write tests
  # This method writes the statement out as a literal string.  In the sense
  # that any of the variables used in the statement are converted to literals
  # and written.  Unknown variables are not written yet though.
  #
  # This method is called during tracking to give an indication what the statement
  # being tracked is doing.
  # 
  # TODO  I am treating unknown variables as a special case that is the same 
  #       value e.g. 'var' - but for determining equivalent processes it isn't
  #       ideal becuase you loose track of what variables is used in each 
  #       statement.  Although I'll wait unitl I can come up with an example
  #       and come up with a solution then.
  #
  def to_literal_string
    return @nodes.inject('') do |complete,part|
      complete += part.to_literal_string
    end
  end  
  
  # Returns the number of statments in the statement.  This will always 
  # be one but nested statements may have more.
  #
  def statement_count
    return 1
  end
  
  # Returns true if the statement contains the same undeclared variables 
  # as the statement provided as well as the same number of elements.
  #
  # @param  statement     The statement thats undeclared variables are being compared.
  #
  def same_not_declared_variables?(statement)
    return false if statement.length != self.length
    statement.not_declared_variables.each do |x|
      return false unless self.not_declared_variables.any? {|y| y.variable_id  == x.variable_id} 
    end
    return true
  end
  
  # Adds this statement to array of overriding statements if it
  # overrides an existing variable.
  #
  # @param  overriding_statements   An array containing other overriding statements.
  #
  def find_overriding_statements(overriding_statements=[])
    overriding_statements.push self if self.overrides? 
    return overriding_statements
  end  
  
  # Returns an updated statement where all the variables within the statement
  # have been realised.  If the statement resides inside a nested statement 
  # or multiple nested statements the variables will be changed into a Dynamic
  # Variable.  These dynamic variables contain multiple variables with different
  # values but the same variable_id.
  #
  # For example:
  #
  # 3.times do |var_a|
  #   var_b = var_a+1
  # end
  #
  # In the above case var_b would be a dynamic variable would contain 3 FixnumVariable
  # with the values 1,2,3.  The statement itself doesn't indicate that it is nested, it
  # is still just a regular statement.  
  #
  # In a more complex example where we have two nested statements we might have something
  # like the following:
  #
  # 2.times do |var_a|
  #   2.times do |var_b|
  #     var_c = var_b+1
  #   end
  # end
  # 
  # We would end up with another dynamic variable with the values 1,2,1,2.
  # 
  # The final tricky situation is when variables are overwritten. As a rule block 
  # variables are never overwritten - I should also include the subject of a loop
  # as well.
  # 
  # For example:
  # 
  # var_a = 0
  # 3.times do |var_b|
  #   var_a += var_b
  # end
  #
  # In this situation there will be 3 versions of var_a the first one, the dynamic internal
  # one and a post statement variable.  The post statement variable will have a statement
  # dependencey on the above nested statement.  The internal variable will have a scope
  # depenencey on the nested statement.
  # 
  # TODO  I suspect my approach to this is wrong.  I pass in the history instance with 
  #       all the information and then try to work out the realised value for this statement
  #       but it would probably be easier if the history instance itself to determine this.
  #   
  def realise2(method_map)
    return copy if realised?

    raise StandardError.new('Unexpected data type ') unless method_map.kind_of?(History)
    # Create a duplcate statement to be modified 
    result = self.copy
    
    # Find value(s) for each unrealised variable.  
    realised_variables = []
    each_unrealised_variable do |x|
      if x.kind_of?(BlockVariable)
        realised_variables.push(method_map.find_realised_variable(x.variable_id,x.uniq_id,'BlockVariable'))
      else
        realised_variables.push(method_map.find_realised_variable(x.variable_id,x.uniq_id))
      end
      # TODO  Change to elsif x.kind_of?(Variable)
    end

    # Substitue the realised variables for the unrealised ones
    self.each_unrealised_variable do |var|
      catch(:variable_substituted) do
        realised_variables.each do |z|
          if z.uniq_id == var.uniq_id
            result.replace_variable!(var.variable_id,z)
            throw :variable_substituted
          end
        end
        raise StandardError.new('Couldn\'t find realised value for variable with id '+var.variable_id.to_s+' in "'+self.write+'"')
      end
    end
    return result
    
  end
  
  # Returns an array of all the RuntimeMethods instances contained in this
  # statement.  In all likelyhood there will no more than one.
  #
  def find_all_required_runtime_methods
    defcalls = @nodes.find_all {|x| x.kind_of?(DefCall)} 
    return defcalls.collect {|x| x.runtime_method}
  end  
  
  # Returns true if the statement has been fully realsied - in that all the variables
  # contained within it are realised.   Otherwise it returns false.
  #
  def realised?
    return self.variables.all? {|x| x.realised?}
  end

  # Returns the statement as a StatementVariable  
  #
  # @param  id    The id of the variable to give to the returned statement
  #               variable.
  #
  def to_var(id=nil,uniq_id=nil)
    var = StatementVariable.new(self.copy)  {{:variable_id => id,:uniq_id=>uniq_id}}
    return var
  end        
  
  # Returns true if the statement declares a variable
  def decalares_variable?
    return true if self[0].kind_of?(Variable) and self[1].kind_of?(Equal)
    return false
  end
  
  # Returns the variable declared in the statement. (if one exists)
  #
  def declared_variable
    raise ImproperStatementUsageError.new(self.write+' does not declare a variable') unless decalares_variable?
    return nil if declared_variable_id.nil?  
    return self[0]
  end   
  
  # Returns true if this statement creates a new variable.  A variable is considered created
  # if it is declared in the variable or it modifies a variable. e.g. var_a.chop! or var_a.push(var_b)
  #
  def creates_variable?
    created_variable
    return true
  rescue ImproperStatementUsageError
    return false
  end
  
  # Returns the id of the created variable in this statement or raises an error if
  # no variable is created.
  #
  def created_variable_id
    return created_variable.variable_id
  end
  
  # Returns the variable created by this statement or raises an error if the 
  # statement doesn't create a variable.
  #
  def created_variable

    # Check if the statement declares a new variable
    begin 
      return declared_variable
    rescue ImproperStatementUsageError => e
      if first.kind_of?(InstanceCallContainer)
        if first.subject.kind_of?(Variable) and first.method_call.destructive?
          return first.subject
        end
      end
      raise ImproperStatementUsageError.new(self.write+' statement does not create a new variable "'+e+"'")
    end
    
  end
  
  # TODO  Write tests for this
  # Returns true if this statement is equivalent to the statement
  # supplied.  They are equalvalent if they have the same length,
  # classes and values.
  #
  # @param  statement     The statement that this statement is being compared to
  #
  def equivalent?(statement)
    return false unless statement.length == self.length

    # TODO  It would be nice to come up with a method to itterate through
    #       groups in an array. 
    #       e.g.  [self,statement].each_pair do |x,y|
    #             end
    #       where x is the first element in self and y is the first element in statement
    # TODO  I think Unknowns should only be accepted if they are the first paramter in
    #       a declaration statement.  Current var_a = Unknown.chop is the same as var_b = var_c.chop
    self.each_with_index do |elem,i|
      return false unless elem.equivalent?(statement[i])
    end
    return true
    
#    # TODO  Tidy this up - pass the element to each other
#    #       e.g.
#    #       self.each_with_index do |elem,i|
#    #         return false unless eleme.equivalent?(statement[i])
#    #       end      
#    # 
#    self.each_with_index do |elem,i|
#      return false if statement[i].class == elem.class
#      if(elem.kind_of?(Variable))
#        return false if elem.variable_id != statement[i].variable_id
#      elsif(elem.kind_of?(InstanceCallContainer))
#        return false if elem.variable_id != statement[i].variable_id
#        return false if elem.method_call != statement[i].method_call
#      end      
#    end 
#    return true
  end
  
  def has?(&block)
    self.each do |x|
      return true if block.call(x)
    end
    return false
  end    
  
  def cauldron_method_calls
    return ['.statement_id']
  end  
  
  def map_to(mapping)
    
    # Duplicate the current statement before it is rewritten
    rewritten_statement = self.copy
    
    # Find all the containers that contain TheoryVariables
    # NOTE  The statement is put in an array because select all doesn't include the array itself
    containers = [rewritten_statement].select_all {|x| x.respond_to?(:has?)}
    theory_variable_containers = containers.select {|x| x.has? {|y| y.kind_of?(Variable)}}
    
    # Rewrite the statement replacing the values
    theory_variable_containers.each do |z|
      z.replace_variables!(mapping)
    end     
    
    return rewritten_statement
    #return TheoryDependent.new(rewritten_statement,@theory_component_id)
  end    
        
protected
  
  # @param  var       The subsitute variable 
  # @param  id        The id of the substitee
  # @param  target    The instance call being substituted
  #
  def subst_instance_call(var,id,target,context)

    # Duplicate the current statement (variables are not in context)
    copied_statement = self.copy  

    # 2.  Outside the context of the statement does the variable meet the requirements
    #begin 
      
      # If the target is a instance call does the new variable meet the requirements of the instance call?
      var_with_instance_call = nil

      # Can the replacing variable be litralised?
      if(var.literalisable?)

        # Change the variable into a literal instance
        begin
          literal_instance = var.literalise
        rescue StandardError => e
          StandardLogger.log('literalise: '+e)
        end
        
        # Retrieve the instance call requirements and use the litralised variable with them
        unless target.method_call.valid_syntax?(literal_instance)
          raise RuntimeSyntaxError.new(literal_instance.write+' doesn\'t have the method "'+target.method_call.write+'"')
        end
        
        # The substitute variable can use the same instance call as the variable being substituted
        var_with_instance_call = InstanceCallContainer.new(var,target.method_call.copy)          

      else
        
        # TODO  Write tests to test variables that can't be literalised
        # self.class == String can use the .chop method call

        # Does the substitute variable meet the requirements of the target variable
        if(var.meets_requirements?(target.subject))
          
          # The individual variables can be replaced - but can it use the same method call as the target
          var_with_instance_call = InstanceCallContainer.new(var,target.method_call.copy)                    
          
        else
          StandardLogger.log(var.write_variable_id+' doesn\'t meet the requirements of '+target.subject.write)

        end
      end

      # At this point the variable being substitued either doesn't make an instance call or makes a valid one
      # Now we need to see whether it is valid with in the context of the statement.

      # Get the requirements added to the variable in the context of the statement
      reqs = requirements_for(target.subject)     

      # If there are no requirements then its fine to use
      if(reqs.empty?)
        copied_statement = self.copy
        #copied_statement.replace_variable!(id,var_with_instance_call)        
        copied_statement.replace_variable!(id,var_with_instance_call.subject)
        return copied_statement        
      end
      StandardLogger.log('Statement: haven\'t accounted for requirements')
      return
     
  end  
  
  #
  # @param  var     The variable that is being substituted into the statement
  # @param  id      The id of the variable to be included in the statement
  # @param  target  The variable in the statement that will be replaced 
  # 
  def subst_variable_call(var,id,target,context)
      
    # The variable must meet the requirements of the statement - so add it to a duplicate statement
    copied_statement = self.copy
    copied_statement.replace_variable!(id,var)
    
    return copied_statement

  end
  
  # Returns a copy of the variable with the id supplied, otherwise
  # raise an exception.  This variable is not in the context of
  # the statement.
  #
  # @param  id    The id of the variable that should exist in this statement
  #
  def copy_original_variable(id)
    self.each do |code|
      next unless code.kind_of? Variable or code.kind_of? InstanceCallContainer
      return code.copy if code.variable_id == id
    end
  end
    
  # Updates any of the requirements of the variables if
  # it's needed and confirms the statement so it can be 
  # used in a method.
  # TODO  This class might be redundant
  #
  # Write tests for exceptable statements
  #
  def update

    # Narrow down what type of statement it is. Does it contain a equal or equivalent sign?
    equivaltent_assignment = detect_class(Equivalent)

    unless equivaltent_assignment.nil?
      begin
        #update_requirements
        @confirmed = true
      rescue InvalidStatementError
      end
      return
    end
    
    # Check if the statement contains return syntax
    if detect_class(Return)
      
      # Check there are two 
      unless self.length == 2
        @confirmed = false
        return
      end
      @confirmed = true
      return
    end
    
    if self.length == 1 and detect_class(DefCall)
      @confirmed = true
    end
    
  end
  
  # Returns the two arrays split between the kind of class
  # provided.
  # 
  # @param  klass   
  #
  def split klass
    
    # Find the index of the equivalent assignment
    equivaltent_assignment = detect_class(klass)
    if equivaltent_assignment.nil? then raise InvalidStatementError.new('No equivalent assignment found when spliting') end
    equalivalent_index = self.index(equivaltent_assignment)
    
    # Slice the array between the two values
    left = self.slice(0...equalivalent_index)
    right = self.slice((equalivalent_index+1)...self.length)    

    # Check there is only ever one thing on the left hand side of the equation
    if(left.length > 1) then throw InvalidStatementError.new('"Equivalent statements" can only have one value on the left hand side') end    

    return [left, right]
    
  end
  
  # Returns the first instance with the class declared.  
  #
  # @param  class_name    The kind of class that is being searched for e.g. Equal or Equivalent
  #
  def detect_class(class_name)
    not_found = lambda{raise StandardError.new(''+class_name.to_s+' could not be found')}
    begin
      return self.detect(not_found) {|x| x.kind_of? class_name}        
    rescue StandardError
      return nil
    end
  end
  
  # Returns the requirement for the declared variable in the statement
  #
  def declared_variable_requirement
    
    # Check that this statement declares a variable (they all should)
    if(detect_class(Equal).nil?)then raise StandardError.new('Expecting statement to declare a variable') end
    
    # Check that the equals sign is the second code
    unless(self[1].kind_of?(Equal)) then raise StandardError.new('Expecting statement to include equal sign as secound code element') end
    
    # Return the requirement of the declared variable
    declaration_requirement = Requirement.new(This.new,Equal.new,*self[2..self.length])                      

    return declaration_requirement
    
  end
  
  # Currently this involves changing the 'uniq_id' of any 
  # variables modified in the statment.
  # e.g. var_a.push(9)
  # 
  def review
    
    # TODO  I have dropped this for now I don't know if it is redundent or not - it effect 
    #       tc_statement.rb test_created_variable 
#    # A modifying statement would be "var_16.push('Normandy SR2')"
#    if statement_type == StatementStructure::MODIFYING_STATEMENT 
#      created_variable.uniq_id_history.push(created_variable.uniq_id)
#      created_variable.increament_uniq_id!
#    end
  rescue StandardError => e
    # TODO  I shouldn't really need this it is just temporary because of the way 
    # structures are created in StatementStructure2.statements - they create a 
    # partial statement.
    StandardLogger.instance.warning(e)
  end
  
end