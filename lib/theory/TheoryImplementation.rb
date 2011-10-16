# Instances of this class are realised theorys.  The theory variables
# have been replaced with values that generate valid ruby code.

class TheoryImplementation
  attr_reader :mapping, :accessor_values, :theory_id, :dependents, :action, :results
  
  #  
  # @param  mapping     The literal mapping indicating what variable should be converted
  #                     to what literal value. {1=><#IntrinsicRuntimeMethod,2=><#IntrinsicLiteral val=9>,...}
  # @param  values      
  #
  def initialize(dependents,action,results,mapping,theory_id,accessor_values={})
    @dependents, @action, @results = dependents, action, results
    @mapping, @accessor_values = mapping, accessor_values
    @theory_id = theory_id
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
  
  # Not DRY see Theory.rb
  # Returns an array of all the theory variables used within the theory.
  # 
  def all_theory_variables
    
    # Get all the theory variables used in the @action, dependents and results 
    a = ([@action]+@dependents+@results).select{|x| x != nil}.inject([]) {|total,x| total += x.theory_variables }
    
    # Filter out only the uniq theory vairables
    # http://stackoverflow.com/questions/109781/uniq-by-object-attribute-in-ruby
    return a.inject({}) {|total,x| total[x.theory_variable_id]=x; total}.values
    
  end    
  
  # Not DRY see Theory.rb
  # @param  mapping   { 1=>[],
  #                     2=>#<IntrinsicTestCases:0xb712d13c>,
  #                     3=>#<IntrinsicRuntimeMethod:0xb712c980>
  #                   }
  # @param  values    {
  #                     1=>0,
  #                     2=><#TestCases>
  #                     3=><#Runtime Method>
  #                   }
  #
  def map_to(mapping,values={})
    raise StandardError.new('Please use the maping datatype') unless mapping.kind_of?(Mapping)
    return TheoryImplementation.new(
        @dependents.collect {|y| y.map_to(mapping)},
        @action ? @action.map_to(mapping) : nil,
        @results.collect {|y| y.map_to(mapping)},
        mapping,
        @theory_id,
        values
      )       
  end    
  
  # Not DRY see Theory.rb
  def write
    
    # Describe the despendencies
    description = 'if: '+"\n"
    @dependents.inject(description) {|description, x| description += x.write(1)+"\n" }
    
    # Describe the action
    unless @action.nil?
      description += "\n"+"action: \n"
      description += @action.write(1)
    end
    
    # Describe the result
    description += "\n"+"result: \n"
    @results.inject(description) {|description, x| description += x.write(1)+"\n" }
    return description    
  end  
  
  # Not DRY see Theory.rb
  def describe
    
    # TODO include - theory_instance_id
    # Describe the despendencies
    description = 'if: '+"\n"
    @dependents.inject(description) {|description, x| description += x.describe(1) }
    
    # Describe the action
    unless @action.nil?
      description += "\n"+"action: \n"
      description += @action.describe(1)
    end
    
    # Describe the result
    description += "\n"+"result: \n"
    @results.inject(description) {|description, x| description += x.describe(1) }
    return description
      
  end  
  
end