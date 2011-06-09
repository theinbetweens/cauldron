# This class is used to evaluate runtime variables.

class MethodEvaluation
  @@COUNTER = 0
  
  def evaluate_method(runtime_method,params,additional_methods=[])

    # Create file to include the runtime method
    filepath = $LOC+File.join(['tmp','runtime_method_evaluation.rb'])    
    #filepath = $LOC+File.join(['tmp','runtime_method_evaluation_'+@@COUNTER.to_s+'.rb'])        
    file = File.open(filepath,'w+')    
    
    # A new class name is created otherwise previously declared method names are peristent.
    # e.g. if a "RuntimeMethodEvaluation" was created with the method_a it would still 
    #      be available even if the class was overridden.
    class_name = 'RuntimeMethodEvaluation'+@@COUNTER.to_s
    @@COUNTER += 1
    # TODO  I shouldn't just be incrementing the counter number - these are separate classes
    file_content = ''
    
    # Include the sytax for the statement in the file
    file_content << 'class '+class_name+"\n"
    file_content << runtime_method.write(
      ParametersContainer.new,1,
      "This is the method that is being evaluated using '#{class_name}.new.#{runtime_method.method_name}"
    ) 
    
    # And any additional methods and close the file
    additional_methods.each do |x|
      file_content << x.write(ParametersContainer.new,1)
    end
    file_content << "\n"+'end'       
    file << file_content
    file.close 

    evaluated_parameters = []
    params.each do |x|
      evaluated_parameters.push(x.value)
    end
  
    # Load the generated class
    load filepath

    # Use the evaluated paramaters with the evaluated runtime method
    return eval("#{class_name}.new."+runtime_method.method_name+"(*evaluated_parameters)")
    
  end
  
end