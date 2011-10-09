module Cauldron
  
  class ChainCollection
    
    include Cauldron::Util::Home
    
    @@cached_saved_theories = nil
    
    def initialize(test_cases)
      @runtime_method = RuntimeMethod.new(MethodUsage.new(MethodParameter.new))
      @test_cases = test_cases    
      @connector = TheoryConnector.new(MappingValues.new([]))
      @chains, @exclude = [], []
    end
    
    def next_chain
      if @chains.empty?
        puts 'saved_theories: '+saved_theories.length.to_s  
        @chains = @connector.generate_chains(@runtime_method,@test_cases,saved_theories,@exclude)
        puts 'Total number of chains: '+@chains.length.to_s        
        if @chains.empty?
          raise StandardError.new('No more chains available')
        end
      end
      chain = @chains.shift
      if @exclude.any? {|x| x == chain.theories_sequence }
        return next_chain
      end
      chain.unify_chain
    end
    
    def exclude(sequence)
      @exclude << sequence
    end
    
    def saved_theories
      # => TODO This needs to cached to prevent error
      if @@cached_saved_theories.nil?
        puts theory_repository_path
        saved_theory_file_paths = Dir.glob(File.join(theory_repository_path,'*','dump'))
        @@cached_saved_theories = saved_theory_file_paths.collect {|x| Marshal.load(File.open(x,'r'))}
        @@cached_saved_theories.freeze
      end
      puts @@cached_saved_theories.length.to_s
      @@cached_saved_theories
    end    
    
    def theory_repository_path
      File.join(home,'cauldron',Cauldron::Pot::VERSION,'theories')
    end     
    
  end 
  
end