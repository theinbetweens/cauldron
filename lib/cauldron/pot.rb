module Cauldron

  class Pot
    include ContainsTheories  
    
    VERSION = '0-01'
    
    def initialize()
      
    end
    
    def brew(test_cases)
      puts 'About to start brewing...'
      
      # * Load each of the theories from the directory
      saved_theory_file_paths = Dir.glob(File.join(theory_repository_path,'*','dump'))
      theories = saved_theory_file_paths.collect {|x| Marshal.load(File.open(x,'r'))}    
      puts theories.length
      
      # Prepare the theory chain connector
      runtime_method = RuntimeMethod.new(MethodUsage.new(MethodParameter.new))    
      tc = Parser.run('test_cases')
      tc_index_0 = IntrinsicLiteral.new(0)
      tc_index_1 = IntrinsicLiteral.new(1)
      param_0 = IntrinsicLiteral.new(0)
      real_method = Parser.run('runtime_method')
      
      # TODO  Still need to include last_real_method
      last_real_method = Parser.run('last_runtime_method')
      
      # Create the thoery connector and the values available 
      # TODO  These values should actually be retreived progressively
      potential_values = MappingValues.new([tc,tc_index_0,tc_index_1,param_0,real_method])     
      connector = TheoryConnector.new(potential_values)        
      
      # Attempt to generate a complete chain for the solution
      chains = connector.generate_chains(runtime_method,test_cases,theories)
      if chains.empty?
        raise StandardError.new('Failed to generate a chain for this problem')
      end       
      
      # Now validate each of the chains to check they work
      # chains.each do |chain|
        # chain_permutations = chain.unify_chain.implementation_permuatations(runtime_method,test_cases,Mapping.new)
      # end
      # TEMP just concentrate of one implementation_permutation
      implementation_permutations = chains.first.unify_chain.implementation_permuatations(runtime_method,test_cases,Mapping.new)
      
      # Go through each of the permutations and create the runtime method for the chain
      validator = TheoryChainValidator.new
      result = validator.build(runtime_method,test_cases,implementation_permutations)
      return result
      
    end
    
    def simmer(demo)
      raise StandardError.new('This demo does not work') unless demo_works?(demo)
      
      # Generate a master theory for each stage of the runtime method when following the theory chains
      generator = TheoryGenerator.new
      master_theories = generator.master_theories(demo[:chain],demo[:initial_method],demo[:test_cases])
      
      # Add each of the theories in the chain to cauldron
      master_theories.each {|x| save_theory(x,master_repository_path)}
      
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
  
    # Check that the home directory exists  
    def home
      realHome = ["HOME", "HOMEPATH"].detect {|h| ENV[h] != nil}
      if not realHome
        StandardLogger.instance.warning "Couldn't detect a home directory"
      end
      return ENV[realHome]  
    end
    
    # Saves the generic theory to file.  This theory will have minimal 
    # dependents and results.
    #
    def save_theory(theory,repository)
      
      # Define the theory's directory
      theory_path = File.join(repository,theory.theory_id.to_s)
      raise StandardError.new('Directory already exists - how as this happened?') if File.exists?(theory_path)
      
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