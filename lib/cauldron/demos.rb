module Cauldron
  
  module Demos
    
    def convert_to_cauldron_test_cases(cases)
      cases.inject([]) do |total,x|
        cauldron_case = CTestCase.new
        cauldron_case[:params] = x[0]
        cauldron_case[:output] = x[1]
        total << cauldron_case
      end
    end     
    
    def demo(id)
      
      if id == '1'
        return demo_one
      end
      raise StandardError.new('Unable to find demo with id '+id)
    
    end
      
    def demo_one
      
      @demo_1_test_cases = convert_to_cauldron_test_cases(
        [
          [['sparky'],'sparky'],
          [['kel'],'kel']
        ]
      )      
      
      # Create demo #1 chain
      #   Create the head for the chain
      head = Theory.new([],nil,[])    
      
      link_one_action = TheoryAction.new(
        TheoryStatement.new(StringToTheory.run('Statement.new(Return.new,var1.params[var3])')),
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
      return {
        :initial_method=>RuntimeMethod.new(MethodUsage.new(MethodParameter.new)),
        :test_cases=>@demo_1_test_cases,
        :chain=>chain,
        :values=>{}
      }            
      
    end
        
    # => "def method_3(var_0)\n\tif(var_0 == 'fish')\n\t\treturn 'animal'\n\tend\n\treturn 'vegetable'\nend\n"
    def demo_two
      @demo_2_test_cases = convert_to_cauldron_test_cases(
        [
          [['fish'],'animal'],
          [['carrot'],'vegtable'],
        ]
      )
      head = Theory.new([],nil,[])
      
      # Statementents
      # => TODO Need a clear way to format theories
      # => OpenStatement.new(If.new,Container.new(runtime_method.params[var1],Equivalent.new,test_cases[var2][:params][var3]))
      # => Statement.new(Return.new,test_cases[var2][:result]) (added to the open statement)
      # => Statement.new(Return.new,test_cases[var6][:result])
      
      link_one_action = TheoryAction.new(
        TheoryStatement.new(StringToTheory.run(
          'OpenStatement.new(If.new,Container.new(var4.params[var1],Equivalent.new,var5[var2][:params][var3]))')
        ),
        StringToTheory.run('var4.statement_id')
      )
      # => TODO Don't like including this (it needs included to identify the runtime method in the next link)
      #"if(var4.kind_of?(RuntimeMethod))\nreturn true\nend"
      # open = OpenStatement.new(TheoryStatement.new(If.new,Container.new(TheoryVariable.new(4))))
      # open << TheoryStatement.new(Return.new,True.new)
      # link_one_result = TheoryResult.new(open) 
      # open3 = OpenStatement.new(TheoryStatement.new(If.new,Container.new(TheoryVariable.new(5))))
      # open3 << TheoryStatement.new(Return.new,True.new)     
      # link_one_result2 = TheoryResult.new(open3) 
      #link_one = Theory.new([],link_one_action,[link_one_result,link_one_result2])
      link_one = Theory.new([],link_one_action,[])

      # open2 = OpenStatement.new(TheoryStatement.new(If.new,Container.new(TheoryVariable.new(4))))
      # open2 << TheoryStatement.new(Return.new,True.new)
      # link_two_dependent = TheoryDependent.new(open2)      
      # open5 = OpenStatement.new(TheoryStatement.new(If.new,Container.new(TheoryVariable.new(5))))
      # open5 << TheoryStatement.new(Return.new,True.new)
      # link_two_dependent_2 = TheoryDependent.new(open5)          
      link_two_action = TheoryAction.new(
        TheoryStatement.new(StringToTheory.run(
          'Statement.new(Return.new,var5[var2][:result])'
        )),
        StringToTheory.run('var4.first.statement_id')
      ) 
      #link_two = Theory.new([link_two_dependent,link_two_dependent_2],link_two_action,[])
      link_two = Theory.new([],link_two_action,[])
      
      link_three_action = TheoryAction.new(
        TheoryStatement.new(
          StringToTheory.run(
            'Statement.new(Return.new,var5[var6][:result])'  
          )
        ),
        StringToTheory.run('var4.statement_id')
      )
      link_three = Theory.new([],link_three_action,[])
      
      link_four_result = TheoryResult.new(StringToTheory.run(
        "if(var4.all_pass?(var5))\nreturn true\nend"
      ))
      link_four = Theory.new([],nil,[link_four_result])
         
      chain = Chain.new
      chain = chain.add_link(head).first
      chains = chain.add_link(
        link_one,
        {
          4=>IntrinsicRuntimeMethod.new,
          5=>IntrinsicTestCases.new,
          1=>IntrinsicLiteral.new(0),
          2=>IntrinsicLiteral.new(0),
          3=>IntrinsicLiteral.new(0)
        }
      )
      chain = chains.first
      
      chains = chain.add_link(
        link_two,
        {
          4=>IntrinsicRuntimeMethod.new,
          5=>IntrinsicTestCases.new,
          1=>IntrinsicLiteral.new(0),
          2=>IntrinsicLiteral.new(0),
          3=>IntrinsicLiteral.new(0),
          6=>IntrinsicLiteral.new(1) 
        }
      )
      chain = chains[1]
      
      chains = chain.add_link(
        link_three,
        {
          4=>IntrinsicRuntimeMethod.new,
          5=>IntrinsicTestCases.new,
          1=>IntrinsicLiteral.new(0),
          2=>IntrinsicLiteral.new(0),
          3=>IntrinsicLiteral.new(0),
          6=>IntrinsicLiteral.new(1) 
        }
      )
      
      chain = chains[2]
      
      chains = chain.add_link(
        link_four,
        {
          4=>IntrinsicRuntimeMethod.new,
          5=>IntrinsicTestCases.new,
          1=>IntrinsicLiteral.new(0),
          2=>IntrinsicLiteral.new(0),
          3=>IntrinsicLiteral.new(0),
          6=>IntrinsicLiteral.new(1)          
        }
      )
      chain = chains[3]
      implemented_chain = chain.implement
      
      return {
        :initial_method=>RuntimeMethod.new(MethodUsage.new(MethodParameter.new)),
        :test_cases=>@demo_2_test_cases,
        :chain=>chain,
        :values=>{}
      }            
                  
    end    

  end
  
end