# This instances of this class describe the consequence of a theory, e.g. if the 
# the theories dependencies are met and the action complete then this will be 
# true.
#
class TheoryResult
  include TheoryComponent
  
  attr_reader :statement
  
  # 
  # @param  statement     A theory statement explaining what will be tested
  #                       e.g. <runtime_method>.all_pass?(<test_cases>)
  #
  def initialize(statement,result=nil,theory_component_id=nil)
    
    # TEMPORARY - Deprecaction Change:
    unless result.nil? then StandardLogger.instance.warning('Result is being phased out - just use if statements') end
    unless statement.kind_of?(OpenStatement) 
      StandardLogger.instance.warning('Please use open statements for theory results') 
    end 
    unless statement.length > 0 
      StandardLogger.instance.warning('Please include a return true statement in the theory result')
    end      
    
    @statement = statement
    @result = result
    @theory_component_id = theory_component_id unless theory_component_id.nil?
    generate_theory_component_id
  end
  
  def describe(tab=0)
    return @statement.describe(tab)
  end

  def write(tab=0)
    return @statement.write(tab)
  end  
  
  def copy
    #return TheoryResult.new(@statement.copy,@result)
    return Marshal.load(Marshal.dump(self))
  end
  
  # Returns a new theory result with the theory variables replaced with
  # the values in the mapping hash.
  #
  # @param  mapping   { 1=>[],
  #                     2=>#<IntrinsicTestCases:0xb712d13c>,
  #                     3=>#<IntrinsicRuntimeMethod:0xb712c980>
  #                   }
  # 
  def map_to(mapping)
    
    # Duplicate the current statement before it is rewritten
    rewritten_statement = @statement.copy
    
    # Find all the containers that contain TheoryVariables
    # NOTE  The statement is put in an array because select all doesn't include the array itself
    containers = [rewritten_statement].select_all {|x| x.respond_to?(:has?)}
    theory_variable_containers = containers.select {|x| x.has? {|y| y.kind_of?(TheoryVariable)}}
    
    # Rewrite the statement replacing the values
    theory_variable_containers.each do |z|
      z.replace_theory_variables!(mapping)
    end     
    
    return TheoryResult.new(rewritten_statement,nil,theory_component_id)
  end
  
  # Returns a mapping hash that will convert this result to the statement 
  # provided.
  #
  def mapping_for(statement)
    mapping = Mapping.new()
    @statement.tokens.zip(statement.tokens) do |x,y|
      mapping[x.theory_variable_id] = y
    end
    return mapping
  end    
  
  # Returns true if supplied statement has the same structure as this theory 
  # result's, it has the same structure if everything about the statement is
  # the same except for the variables.  This means that the map_to method
  # could be used to make it write identically.
  #
  def same_structure?(structure)
      return false unless structure.tokens.length == @statement.tokens.length
      return false unless structure.write_structure == @statement.write_structure
      return true
  end
  
  # Returns true if theory result is true with the supplied
  # runtime method and test cases.  The paramter are 'rutime_method'
  # and 'test_cases' so the eval can use them.
  #
  # TODO  Write tests for this
  def validates?(runtime_method,test_cases)
    catch :theory_result_failed do 
      return true if use_statement(runtime_method,test_cases) == true
    end
    return false
  end  
  
protected 
  
  # This uses the result statement with the supplied values so  
  # the result can be evaluted.
  #
  def use_statement(runtime_method,test_cases)
    duplicate_statement = @statement.copy
    # TODO  I'm not certaion with is how last_runtime is being used - see spec
    last_runtime_method = runtime_method.copy
    begin
    rescue StandardError => e
    end
#    if((last_runtime_method.history2(test_cases[0]).select{ |x| x['statement_id'] == test_cases.last.statement_id} ) == test_cases[0][:params][0].length - 1)
#      #return true
#    end
    
    #last_runtime_method.history2(test_cases[0][:params]).each do |x|
    #end
    # TODO    For future debugging I really need to generate a runtime method from a string.
    eval duplicate_statement.write
    throw :theory_result_failed
  rescue NoMethodError => e
    throw :theory_result_failed
  rescue TypeError => e
    throw :theory_result_failed
  end
  
end