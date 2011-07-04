
# Used to make calls to a dynamically written class.
#
class ClassEvaluation
  @@count = 0
  
  def evaluate_class(runtime_class,runtime_call)    
    return evaluate_class_2(runtime_class,runtime_call)
  end
  
  def evaluate_class_2(runtime_class,runtime_call,*params)
    
    # Create file to include the test method
    file = Tempfile.new(runtime_class.class_name+'.rb')
    @@count += 1
    
    # Include the sytax for the statement in the file
    file << runtime_class.write
    file.close
    
    # Load the newly created class and check the statement
    load file.path
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
    ensure 
      file.close
      file.unlink
    end  
    
  end
  
  
end