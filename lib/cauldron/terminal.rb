module Cauldron
  
  class Terminal
    
    include Cauldron::Conversion
    
    attr_reader :cases
    
    def initialize(output,auto=true)
      @output, @cases,@auto = output, [], auto
    end
    
    def start
      @output.puts 'Starting....'
      @pot = Cauldron::Pot.new
      @pot.clear
      @output.puts '* Adding example case'      
      @pot.simmer(demo('1'))
      
      @output.puts "Thanks for trying Cauldron - it's at really early stage right now"
      @output.puts "in fact it can only generate a method that returns the parameter passed through"
      @output.puts ""
      @output.puts "To start enter your first test like this"    
      @output.puts "input,input,output"
      @output.puts "For example "
      @output.puts "'fish','animal'"
      @output.puts "'cat','animal'"
      @output.puts "'carrot','vegtable'"
      @output.puts "and when you're done just type RUN"
      
      # Wait for the user's inputs
      unless @auto
        loop do 
          submit gets
        end      
      end
    end
    
    def submit(input)
      if input =~ /^RUN$/
         @output.puts @pot.brew(@cases).basic_write
      else
        @cases << convert_to_example(separate_values(input))
      end
    end

   # => ==========================================================================
    
    def convert_to_cauldron_test_cases(cases)
      cases.inject([]) do |total,x|
        cauldron_case = CTestCase.new
        cauldron_case[:params] = x[0]
        cauldron_case[:output] = x[1]
        total << cauldron_case
      end
    end    
    
    def demo(id)
      
        @demo_1_test_cases = convert_to_cauldron_test_cases(
          [
            [['sparky'],'sparky'],
            [['kel'],'kel']
          ]
        )
        
        # Create demonstration #2
        demo_2_test_case_1 = CTestCase.new 
        demo_2_test_case_1[:params] = ['something']
        demo_2_test_case_1[:output] = 'exists'
        demo_2_test_case_2 = CTestCase.new
        demo_2_test_case_2[:params] = ['my willpower']
        demo_2_test_case_2[:output] = 'does not exist'
        demo_2_test_cases = [
          demo_2_test_case_1,demo_2_test_case_2
        ] 
        
        # Create demo #1 chain
        #   Create the head for the chain
        head = Theory.new([],nil,[])    
        
        link_one_action = TheoryAction.new(
          TheoryStatement.new(StringToTheory.run('Statement.new(Return.new,var2.params[var3])')),
          StringToTheory.run('var1.statement_id')
        )
        # NOTE: I need to add one result so the theory can be flagged as complete - I might not need it 
        #       to be complete -
        link_one_result = TheoryResult.new(StringToTheory.run("if(var1.all_pass?(var2))\nreturn true\nend"))
        link_one = Theory.new([],link_one_action,[link_one_result])
        chain = Chain.new
        chain = chain.add_link(head).first
        chain = chain.add_link(
          link_one,
          {
            1=>IntrinsicRuntimeMethod.new,
            2=>IntrinsicTestCases.new,
            3=>IntrinsicLiteral.new(0)
          }
        ).first
        
        # Now implement the chain
        implemented_chain = chain.implement
        
        # TODO  It should generate the values too.(TheoryGenerator)
        @demo_1 = {
          :initial_method=>RuntimeMethod.new(MethodUsage.new(MethodParameter.new)),
          :test_cases=>@demo_1_test_cases,
          :chain=>chain,
          :values=>{}
        }  
        
        if id == '1'
          return @demo_1
        end
      
      end    

  end
  
end