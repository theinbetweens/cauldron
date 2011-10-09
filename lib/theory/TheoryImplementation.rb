# Instances of this class are realised theorys.  The theory variables
# have been replaced with values that generate valid ruby code.

class TheoryImplementation < Theory
  attr_reader :mapping, :accessor_values
  
  #  
  # @param  mapping     The literal mapping indicating what variable should be converted
  #                     to what literal value. {1=><#IntrinsicRuntimeMethod,2=><#IntrinsicLiteral val=9>,...}
  # @param  values      
  #
  def initialize(dependents,action,results,mapping,accessor_values={})
    @dependents, @action, @results = dependents, action, results
    @mapping, @accessor_values = mapping, accessor_values
    @theory_id = Theory.next_theory_id
  end
  
  def copy
    #return TheoryImplementation.new(@dependents.copy, @action.copy, @results.copy,@mapping.copy)
     return Marshal.load(Marshal.dump(self))
  end
  
  # Returns true if the result descript matches any of the results
  # for this theory.
  #
  # @param  result_description      A OpenStatement with an if statement inside e.g.
  #                                 if(runtime_method.all_pass?(test_cases))
  #                                 end
  #
  def leads_to?(result_description)
    @results.any? {|x| x.statement.write == result_description.write}
  end  
  
  # Returns true if the implemeted theories pass given the
  # given runtime method and test cases.
  # 
  # TODO  There might be a bit of crossover between the TheoryResult validates?
  #       method.
  #
  def meets_dependencies?(runtime_method,test_cases)
    
    self.dependents.collect {|y| y.copy}.each do |x|
      # TODO  I'm not sure there is much benefit in the ParametersContainer class
      begin
        unless evaluate_dependent(x,runtime_method.copy,test_cases)
          return false
        end
      rescue NoMethodError => e
        return false
      rescue StandardError => e
        return false
      end      
      
    end
    return true    

  end
  
  # TODO  If I remove the code from this method then tc_theory_implementation.rb still
  #       passes all the tests!
  def evaluate_dependent(dependent,runtime_method,test_cases)
    #dependent.statement.push(Parser.run('return true'))
    last_runtime_method = runtime_method.copy
    eval dependent.statement.write 
    return false
  end

  def hash
    @theory_id
  end
  
  def eql?(value)
    @theory_id == value.theory_id
  end
  
end