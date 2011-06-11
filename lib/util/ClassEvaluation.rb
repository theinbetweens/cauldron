# Used to make calls to a dynamically written class.
#
class ClassEvaluation
  #include WriteParameters
  @@count = 0
  
  # TODO  What is original_method about - can I get rid of it.  I need to 
  #       pass through parameters. 
  #
  def evaluate_class(runtime_class,runtime_call,original_method=nil)
    
    # Create file to include the test method
    #filepath = $LOC+File.join(['tmp','runtime_class_evaluation.rb'])    
    filepath = $LOC+File.join(['tmp',runtime_class.class_name+'.rb'])        
    file = File.open(filepath,'w+')
    @@count += 1
    
    # Include the sytax for the statement in the file
    file << runtime_class.write
    file.close

    # Load the newly created class and check the statement
    load filepath
    begin 
      return eval("#{runtime_class.class_name}.new.#{runtime_call}")
    rescue NameError => e
      StandardLogger.instance.error(original_method.write()) unless original_method.nil?
      StandardLogger.instance.info(runtime_class.write)
      raise e
    end
    
  end
  
  # TODO  This duplicates allot of the code above
  def evaluate_class_2(runtime_class,runtime_call,*params)
    
    # Create file to include the test method
    #filepath = $LOC+File.join(['tmp','runtime_class_evaluation.rb'])    
    filepath = $LOC+File.join(['tmp',runtime_class.class_name+'.rb'])        
    file = File.open(filepath,'w+')
    @@count += 1
    
    # Include the sytax for the statement in the file
    file << runtime_class.write
    file.close
    
    # Load the newly created class and check the statement
    load filepath
    begin 
      # TODO  Make this more generic
      case params.length 
        when 0
          return eval("#{runtime_class.class_name}.new.#{runtime_call}")
        when 1
          return eval("#{runtime_class.class_name}.new.#{runtime_call}(params[0])")
      else
        raise StandardError.new('Can only handle one parameter right now')
      end
    rescue NameError => e
      StandardLogger.instance.info(runtime_class.write)
      raise e
    end    
    
  end
  
  
end