# Instances of this class receive a chain of order theories and proceed
# to apply each of them and confirm their expected output.  The valid chain
# can then be used to generate an appropriate runtime method.
#
class TheoryChainValidator
  
  # TODO  Is 'potential_values' used?
  # Returns the first runtime method that could be created with the implemented chains
  # supplied.  This actually generates the runtime method to check the links of the chain
  # are accurate - unlike the complete? check in chain instances.
  #
  def build(runtime_method,test_cases,theory_implementation_chains,potential_values=[])
      validated_chains = []
      theory_implementation_chains.each do |chain|
        validate_next_chain_link(validated_chains,chain,runtime_method.copy,test_cases,0)
      end  
      raise StandardError.new('Failed to generate a valid runtime method') if validated_chains.length == 0
      
      # Select the first chain and return the runtime method it generates
      puts '==========================BUILDING METHOD FROM CHAIN ============================'
      results =  build_method_from_chain(validated_chains.first,runtime_method.copy,test_cases)
      puts 'results.length: '+results.length.to_s
      return results
      
  end 
  
  # Validates that the next link in the chain is consistent with the 
  # theories expected result.  If it is then the next link is checked
  # and so on.  if all the links are consistent then the chain is add
  # to the validated chain array.
  # 
  def validate_next_chain_link(validated_chains,chain,runtime_method,test_cases,position)
    
    # Check that current link in the chain meets in dependencies 
    # if its dependents are met it isn't suppose to work
    unless chain[position].meets_dependencies?(runtime_method.copy,test_cases.copy)
      return nil
    end
    
    # Add the theories action to the chains runtime method and realise the runtime method
    # TODO  This creates a new runtime method each time (so ignores what the previous theory did - BAD)
    result = runtime_method.copy
    unless chain[position].action.nil? 
      begin
        result = add_statement_to_method(test_cases,runtime_method.copy,chain[position].action)
      rescue SyntaxError => e
        StandardLogger.instance.warn e
        return nil
      rescue TypeError => e
        StandardLogger.instance.warn e
        return nil
      end
      
    end
    
    # Now check that the runtime method with the theories action also responds
    # as the theory said it would in the result.
    if chain[position].results.all? {|x| x.validates?(result,test_cases)}
      
      # Has the chain been completed?
      if (position+1) == chain.length
        validated_chains << chain 
        return
      else
        # Continue along the chain
        validate_next_chain_link(validated_chains,chain,result,test_cases,(position+1))
      end
    else
      # Theory was wrong
      # chain[position].results.each do |x|
        # unless x.validates?(result,test_cases)
          # StandardLogger.instance.info('The following result failed to be met')
          # StandardLogger.instance.info(x.write)
        # end
      # end
      return nil
    end    
    
  end
  
  # Builds the method using the chain without checking that the depenedents
  # and results are accurate. 
  #
  def build_method_from_chain(chain,runtime_method,test_cases)
    runtime_method = runtime_method.copy
    chain.each do |link|
      next if link.action.nil?
      runtime_method = add_statement_to_method(test_cases,runtime_method,link.action)
    end
    return runtime_method
  end
  
  def add_statement_to_method(test_cases,runtime_method,action)
    evaluation_code = ''
    # TODO  I don't think this line below is needed
    evaluation_code += "test_cases = #{test_cases.write}"+"\n"
    evaluation_code += "last_runtime_method = runtime_method.copy"+"\n"
    evaluation_code += action.write+"\n"
    evaluation_code += 'return runtime_method'+"\n"
    eval evaluation_code    
  rescue NoMethodError => e
    return nil
  end  
  
end