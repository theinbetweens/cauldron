
module ActsAsRuntimeMethod
  include WriteParameters
  
  # TODO  Write tests
  # Returns a variable instance with the id specified.  This essential just finds the varialbe
  # at the last line of the method.
  # 
  # @param  id  The uniq id of the variable that is being looked for - this should be the unique
  #             variable id.
  #
  def find_variable(uniq_id)
    #return find_variable_at_line(id,self.length)
    #statement_count
    # TODO  I don't know whether I should be using statement_count, self.length or line_count
    #return find_variable_at_line(id,self.length)
    
    # TODO  I don't know if progressively building up the method is necessary now
    
    # TODO  This method can probably be just used in StatementGroup and shared between nested statement 
    #       and runtime method.
    self.each do |x|

      # TODO  SHould be unique variable id
      if x.kind_of?(Statement)
        if x.created_variable.uniq_id == uniq_id
          temp = x.find_actual_variable(uniq_id)
          return temp.copy
        end
        next
      end
      if x.kind_of?(BlockStatement)
        begin 
          # TODO  Write tests for this using uniq_id
          return x.find_variable(uniq_id)
          # TODO   Should have a custom FailedToFindVariable error or similar
        rescue StandardError
          next
        end
      end
    end
    raise FailedToFindVariableError.new('Unable to find variable '+uniq_id.to_s+' in method '+method_id.to_s)
  end  
  
  # TODO  Write tests esp when I start to bring out varients of the same variable
  #
  def find_statement_that_declares_variable(variable_id)
    self.each do |x|
      if x.kind_of?(Statement)
        if x.declared_variable_id == variable_id then return x.copy end
        next
      end
      if x.kind_of?(BlockStatement)
        begin 
          return x.find_statement_that_declares_variable(variable_id)
        rescue StandardError
          next
        end
      end
    end
    raise StandardError.new('Failed to find statement that declared variable '+variable_id.to_s)
  end  
  
  # TODO  Write tests
  def find_statement_that_created_variable(uniq_id)
    self.each do |x|
      if x.kind_of?(Statement)
        if x.created_variable.uniq_id == uniq_id then return x.copy end
        next
      end
      if x.kind_of?(BlockStatement)
        begin 
          return x.find_statement_that_created_variable(variable_id)
        rescue StandardError
          next
        end
      end
    end
    raise StandardError.new('Failed to find statement that created variable with uniq id '+uniq_id.to_s)    
  end
  
  def method_name
    return 'method_'+@method_id.to_s
  end  
  
  # Writes out the runtime method for general use.  If the parameters are supplied 
  # then they are used, otherwise the methods usage parameters are used.
  #
  # @param  params      
  # @param  tab 
  # @param  additional_comments
  #
  def write(params=nil,tab=0,additional_comments=nil)
    
    # Check that the paramters have been defined for the method before it can be written
    # raise_if_parameters_missing
    raise StandardError.new('Incorrect use of write ') if params.kind_of?(Fixnum)
      
    line = "\n"    
    tab.times {|x| line += "\t" }
    line += "#\n"

    if params.nil?

      @usage.each_with_index do |var,i|
      
        tab.times {|x| line += "\t" }
        line += "#\t@param\t"
        
        # Get a description of the requirements (this can multiple lines)
        line_prefix = ''  
        desc = var.describe(tab)
        desc.each_line do |l|
          line += line_prefix+l
          
          # Assides the first line pre-fix a "#      " to the start
          (tab-1).times {|x| line += "\t" }
          line_prefix = "#\t\t\t"
          
        end
        
      end    
      
    else
      
      params.each_with_index do |var,i|       
        tab.times {|x| line += "\t" }
        line += "#\t@param\t"

        # Get a description of the requirements (this can multiple lines)
        line_prefix = ''
  
        desc = var.describe(tab)
        desc.each_line do |l|
          line += line_prefix+l
          
          # Assides the first line pre-fix a "#      " to the start
          (tab-1).times {|x| line += "\t" }
          line_prefix = "#\t\t\t"
          
        end
        
      end
      
    end 
    
    # Add some some additional comment if supplied
    unless additional_comments.nil?
      tab.times {|x| line += "\t" }
      line += "#"
      tab.times {|x| line += "\t" }
      line += additional_comments+"\n"
    end    
    
    tab.times {|x| line += "\t" }
    line += "#\n"               
    
    tab.times {|x| line += "\t"}
    line += basic_write(tab)

  end
  
  def basic_write(tab=0)
    line = ''
    line += 'def '+method_name 
    
    #line += write_params(@parameters)
    line += write_params(@usage)
    line += "\n"
    
    # Write out any statements within the method
    self.each do |statement|
      line += statement.write(tab+1)+"\n"
    end
    #line += "\n" if self.empty?
    
    # Close the method
    tab.times {|x| line += "\t" }
    line += "end"+"\n"
    
    return line    
  end  
  
  # [DEBUG] Does the same as the write method but includes the uniq_id
  #
  # TODO  This duplicates allot of the code in write 
  #
  def write_with_uniq_id(params=nil,tab=0,additional_comments=nil)
    
    # Check that the paramters have been defined for the method before it can be written
    # raise_if_parameters_missing
    raise StandardError.new('Incorrect use of write ') if params.kind_of?(Fixnum)
      
    line = "\n"    
    tab.times {|x| line += "\t" }
    line += "#\n"

    if params.nil?

      @usage.each_with_index do |var,i|
      
        tab.times {|x| line += "\t" }
        line += "#\t@param\t"
        
        # Get a description of the requirements (this can multiple lines)
        line_prefix = ''  
        desc = var.describe(tab)
        desc.each_line do |l|
          line += line_prefix+l
          
          # Assides the first line pre-fix a "#      " to the start
          (tab-1).times {|x| line += "\t" }
          line_prefix = "#\t\t\t"
          
        end
        
      end    
      
    else
      
      params.each_with_index do |var,i|       
        tab.times {|x| line += "\t" }
        line += "#\t@param\t"

        # Get a description of the requirements (this can multiple lines)
        line_prefix = ''
  
        desc = var.describe(tab)
        desc.each_line do |l|
          line += line_prefix+l
          
          # Assides the first line pre-fix a "#      " to the start
          (tab-1).times {|x| line += "\t" }
          line_prefix = "#\t\t\t"
          
        end
        
      end
      
    end 
    
    # Add some some additional comment if supplied
    unless additional_comments.nil?
      tab.times {|x| line += "\t" }
      line += "#"
      tab.times {|x| line += "\t" }
      line += additional_comments+"\n"
    end    
    
    tab.times {|x| line += "\t" }
    line += "#\n"               
    
    tab.times {|x| line += "\t"}
    line += 'def '+method_name 
    
    #line += write_params(@parameters)
    line += write_params(@usage)
    line += "\n"
    
    # Write out any statements within the method
    self.each do |statement|
      line += statement.write_with_uniq_id(tab+1)+"\n"
    end
    line += "\n" if self.empty?
    
    # Close the method
    tab.times {|x| line += "\t" }
    line += "end"+"\n"
    
    return line    
    
  end
  
  # Returns an array of variables currently available in the 
  # method.  Essentially this is all the variables after the 
  # last statement.  This is a little crude since it doesn't 
  # take into account if statements or loops.
  #
  def available_variables(params=[])
    
    # raise StandardError.new('The parameters have not been set for this method') if @parameters.nil? 
    collected_variables = []
    collected_variables += params
    self.each do |statement|
      
        # Nested statements don't provide any variables for the end of the method
        next if statement.kind_of?(BlockStatement)
        next if statement.kind_of?(OpenStatement)
      
        statement.each_variable do |var|
          unless collected_variables.any? {|known_var| known_var.variable_id == var.variable_id}
            collected_variables.push(var.copy)
          end
        end
    end
    return collected_variables
    
  end  
  
end