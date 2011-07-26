module Cauldron

  class Pot
    
    include Cauldron::Util::Home
    include ContainsTheories
      
    
    VERSION = '0-1-1'
    
    def initialize()
      StandardLogger.instance.level = Logger::FATAL
    end
    
    def brew(test_cases)
      
      exclude = []
      chain = next_chain(test_cases,exclude)  
      if chain.nil?
        raise StandardError.new('Failed to generate a chain for this problem')
      end       
      
      runtime_method = RuntimeMethod.new(MethodUsage.new(MethodParameter.new))
      if chain_valid?(chain,test_cases.copy)
        validator = TheoryChainValidator.new
        unified_chain = chain.unify_chain
        implementation_permutations = unified_chain.implementation_permuatations(runtime_method.copy,test_cases.copy,Mapping.new)
        return validator.build(runtime_method.copy,test_cases.copy,implementation_permutations)
      else
        exclude << chain.theories_sequence
        chain = next_chain(test_cases,exclude)
        if chain_valid?(chain,test_cases.copy)
          validator = TheoryChainValidator.new
          unified_chain = chain.unify_chain
          implementation_permutations = unified_chain.implementation_permuatations(runtime_method.copy,test_cases.copy,Mapping.new)
          return validator.build(runtime_method.copy,test_cases.copy,implementation_permutations)
        end        
      end
      return nil
      
    end
    
    def chain_valid?(chain,test_cases)
      runtime_method = RuntimeMethod.new(MethodUsage.new(MethodParameter.new))
      unified_chain = chain.unify_chain
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
    
    def complete_chains(test_cases)
      return [next_chain(test_cases)]
    end
    
    def next_chain(test_cases,exclude=[])
      
      theories = saved_theories 
      
      res = theories.collect {|x| x.theory_id }

      runtime_method = RuntimeMethod.new(MethodUsage.new(MethodParameter.new))    

      potential_values = MappingValues.new([])
      connector = TheoryConnector.new(potential_values)        
      
      # Attempt to generate a complete chain for the solution
      chains = connector.generate_chains(runtime_method,test_cases,theories,exclude)      
      return chains.first
            
    end    
    
    def saved_theories
      saved_theory_file_paths = Dir.glob(File.join(theory_repository_path,'*','dump'))
      saved_theory_file_paths.collect {|x| Marshal.load(File.open(x,'r'))}        
    end
    
    def simmer(demo)
      raise StandardError.new('This demo does not work') unless demo_works?(demo)
      
      # Generate a master theory for each stage of the runtime method when following the theory chains
      # generator = TheoryGenerator.new
      # master_theories = generator.master_theories(
        # demo[:chain],
        # demo[:initial_method],
        # demo[:test_cases]
      # )
      
      # Add each of the theories in the chain to cauldron
      #master_theories.each {|x| save_theory(x,master_repository_path)}
      
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
      cauldron_repository_paths = File.join(home,'cauldron',VERSION,'*')
      FileUtils.rm_r Dir.glob(cauldron_repository_paths)
    end
    
  private 
  
    # # Check that the home directory exists  
    # def home
      # realHome = ["HOME", "HOMEPATH"].detect {|h| ENV[h] != nil}
      # if not realHome
        # StandardLogger.instance.warning "Couldn't detect a home directory"
      # end
      # return ENV[realHome]  
    # end
    
    # Saves the generic theory to file.  This theory will have minimal 
    # dependents and results.
    #
    def save_theory(theory,repository)
      
      # Define the theory's directory
      theory_path = File.join(repository,theory.theory_id.to_s)
      if File.exists?(theory_path)
        puts theory_path+' already exists'
        #raise StandardError.new('Directory already exists - how as this happened?') if File.exists?(theory_path)
        return
      end
      
      # Save a file containing the theory
      FileUtils.mkdir_p(theory_path)
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