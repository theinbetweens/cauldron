module Cauldron

  class Pot
    
    include Cauldron::Util::Home
    include ContainsTheories
      
    VERSION = '0-1-3'
    
    @@brew_count = 0
    
    def initialize()
      StandardLogger.instance.level = Logger::FATAL
    end
    
    # Returns a runtime method that meets the requirements of the test cases.
    def brew(test_cases)
      @@brew_count += 1
      puts "#{@@brew_count} - TestCases: "
      pp test_cases  
      @chain_collection = ChainCollection.new(test_cases.copy)      
      loop do
        runtime_method = RuntimeMethod.new(MethodUsage.new(MethodParameter.new))
        chain = @chain_collection.next_chain
        if unified_chain_valid?(chain,test_cases.copy)
          validator = TheoryChainValidator.new
          implementation_permutations = chain.implementation_permuatations(runtime_method.copy,test_cases.copy,Mapping.new)
 
          return validator.build(runtime_method.copy,test_cases.copy,implementation_permutations)          
        else
          puts '****************************************'
          puts '* Chain is not valid: '
          puts chain.class.to_s
          puts chain.describe
          puts '* for test_cases'
          pp test_cases
        end
      end      
    end
    
    def unified_chain_valid?(unified_chain,test_cases)
      if unified_chain.kind_of?(Array)
        raise StandardError.new('should be a chain '+unified_chain.first.class.to_s) 
      end
      runtime_method = RuntimeMethod.new(MethodUsage.new(MethodParameter.new))
      
      implementation_permutations = unified_chain.implementation_permuatations(runtime_method.copy,test_cases.copy,Mapping.new)  
      
      # Go through each of the permutations and create the runtime method for the chain
      validator = TheoryChainValidator.new
      begin 
        result = validator.build(runtime_method.copy,test_cases.copy,implementation_permutations)
      rescue StandardError => e
        StandardLogger.instance.warning e 
        return false
      end
      return true      
    end    
    
    def simmer(demo)
      raise StandardError.new('This demo does not work') unless demo_works?(demo)
      
      # Save each of the simple versions of the theory
      demo[:chain].each {|x| save_theory(x,theory_repository_path)}
           
    end
    
    # Uses the chain in the demo to construct a runtime method and then checks that 
    # the runtime method indeed solves the example supplied.
    #
    def demo_works?(demo)
      begin 
        runtime_method = TheoryChainValidator.new.build(
                                                          demo[:initial_method],
                                                          demo[:test_cases],
                                                          [demo[:chain].implement]
                                                        )
      rescue StandardError => e
        StandardLogger.instance.warning e
        return false
      end
      return true
    end
   
    # Removes all the saved theories to start a fresh
    def clear
      puts '* Clearing theories'
      cauldron_repository_paths = File.join(home,'cauldron',VERSION,'*')
      FileUtils.rm_r Dir.glob(cauldron_repository_paths)
      Cauldron::ChainCollection.clear_cache!
    end
    
  private 
    
    # Saves the generic theory to file.  This theory will have minimal 
    # dependents and results.
    #
    def save_theory(theory,repository)
      puts '* ----------SAVING THEORY'
      # Define the theory's directory
      theory_path = File.join(repository,theory.theory_id.to_s)
      if File.exists?(theory_path)
        StandardLogger.instance.warning theory_path+' already exists'
        return
      end
      
      # Save a file containing the theory
      FileUtils.mkdir_p(theory_path)
      puts '* ::::'+theory_path
      dump_file = File.open(File.join(theory_path,'dump'),'w+')
      data = Marshal.dump(theory)
      dump_file << data
      dump_file.close       
      
      desc_file = File.open(File.join(theory_path,'desc'),'w+')
      desc_file << theory.write
      desc_file.close    
           
    end
    
    def master_repository_path
      File.join(home,'cauldron',VERSION,'master-theories')
    end
    
    def theory_repository_path
      File.join(home,'cauldron',VERSION,'theories')
    end  
    
  end
end