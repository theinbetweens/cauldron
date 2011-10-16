module Cauldron
  
  class ChainCollection
    
    include Cauldron::Util::Home
    
    @@cached_saved_theories = nil
    
    def initialize(test_cases)
      @runtime_method = RuntimeMethod.new(MethodUsage.new(MethodParameter.new))
      @test_cases = test_cases  
      @connector = TheoryConnector.new(MappingValues.new([]))
      @chains, @exclude = [], []
      @chains = @connector.generate_chains(@runtime_method,@test_cases,saved_theories,[])
    end
    
    def next_chain
      puts 'Total number of chains: '+@chains.length.to_s
      until @chains.empty?
        chain = @chains.shift
        unified_chain = chain.unify_chain
        unless @exclude.any? {|x| x == unified_chain.theories_sequence }
          return unified_chain
        end        
      end
      raise StandardError.new('No more chains available')
    end
    
    def exclude(sequence)
      @exclude << sequence
    end
    
    def saved_theories
      # => TODO This needs to cached to prevent error
      if @@cached_saved_theories.nil?
        saved_theory_file_paths = Dir.glob(File.join(theory_repository_path,'*','dump'))
        @@cached_saved_theories = saved_theory_file_paths.collect {|x| Marshal.load(File.open(x,'r'))}
        @@cached_saved_theories.freeze
      end
      @@cached_saved_theories
    end    
    
    def self.clear_cache!
      @@cached_saved_theories = nil
    end
    
    def theory_repository_path
      File.join(home,'cauldron',Cauldron::Pot::VERSION,'theories')
    end     
    
  end 
  
end