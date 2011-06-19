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
      
      # => TODO Don't actually want to include these connection hacks
      
      # => HEAD
      head_result = TheoryResult.new(StringToTheory.run(
        "if(var1.kind_of?(RuntimeMethod))\nreturn true\nend")
      )
      head_result_2 = TheoryResult.new(StringToTheory.run(
        "if(var2.length == 2)\nreturn true\nend")
      )      
      head = Theory.new([],nil,[head_result,head_result_2])
      
      # => LINK #1
      link_one_dependent = TheoryDependent.new(StringToTheory.run(
          "if(var1.kind_of?(RuntimeMethod))\nreturn true\nend"
        )
      )
      link_one_dependent_2 = TheoryDependent.new(StringToTheory.run(
        "if(var2.length == 2)\nreturn true\nend")
      )       
      link_one_action = TheoryAction.new(
        TheoryStatement.new(StringToTheory.run(
          'OpenStatement.new(If.new,Container.new(var1.params[var3],Equivalent.new,var2[var4][:params][var5]))')
        ),
        StringToTheory.run('var1.statement_id')
      )
      link_one_result = TheoryResult.new(StringToTheory.run(
        "if(var1.kind_of?(RuntimeMethod))\nreturn true\nend"
      ))
      link_one_result_2 = TheoryResult.new(StringToTheory.run(
        "if(var2.length == 2)\nreturn true\nend"
      ))
      link_one_result_3 = TheoryResult.new(StringToTheory.run(
        "if(var4.kind_of?(Fixnum))\nreturn true\nend"
      ))            
      link_one = Theory.new([link_one_dependent,link_one_dependent_2],link_one_action,[link_one_result,link_one_result_2,link_one_result_3])      
      
      # => LINK #2
      link_two_dependent = TheoryDependent.new(StringToTheory.run(
        "if(var1.kind_of?(RuntimeMethod))\nreturn true\nend"
      ))
      link_two_dependent_2 = TheoryDependent.new(StringToTheory.run(
        "if(var2.length == 2)\nreturn true\nend"
      ))
      link_two_dependent_3 = TheoryDependent.new(StringToTheory.run(
        "if(var4.kind_of?(Fixnum))\nreturn true\nend"
      ))                                    
      link_two_action = TheoryAction.new(
        TheoryStatement.new(StringToTheory.run(
          'Statement.new(Return.new,var2[var4][:result])'
        )),
        StringToTheory.run('var1.first.statement_id')
      )
      link_two_result = TheoryResult.new(StringToTheory.run(
        "if(var1.history(var2[var4][:params]) == var2[var4][:output])\nreturn true\nend"
      ))   
      # TODO  Don't want to have to include this one
      link_two_result_2 = TheoryResult.new(StringToTheory.run(
        "if(var6.kind_of?(Fixnum))\nreturn true\nend"
      ))
                     
      link_two = Theory.new(
        [link_two_dependent,link_two_dependent_2,link_two_dependent_3],
        link_two_action,
        [link_two_result,link_two_result_2]
      )      
      
      # => LINK #3
      link_three_dependent = TheoryDependent.new(StringToTheory.run(
        "if(var1.history(var2[var4][:params]) == var2[var4][:output])\nreturn true\nend"        
      ))   
      link_three_dependent_2 = TheoryDependent.new(StringToTheory.run(
        "if(var6.kind_of?(Fixnum))\nreturn true\nend"
      ))
      link_three_action = TheoryAction.new(
        TheoryStatement.new(
          StringToTheory.run(
            'Statement.new(Return.new,var2[var6][:result])'  
          )
        ),
        StringToTheory.run('var1.statement_id')
      )
      link_three_result = TheoryResult.new(StringToTheory.run(
        "if(var1.history(var2[var6][:params]) == var2[var6][:output])\nreturn true\nend"
      ))
      link_three = Theory.new([link_three_dependent,link_three_dependent_2],link_three_action,[link_three_result])         
      
      # => LINK #4
      link_four_dependent = TheoryDependent.new(StringToTheory.run(
        "if(var1.history(var2[var6][:params]) == var2[var6][:output])\nreturn true\nend"
      ))      
      link_four_result = TheoryResult.new(StringToTheory.run(
        "if(var1.all_pass?(var2))\nreturn true\nend"
      ))
      link_four = Theory.new([link_four_dependent],nil,[link_four_result])      
      
      chain = Chain.new
      chains = chain.add_link(head)
      chain = chains.first
      
      head_id = chain.first.theory_id
      last_id = chain.last.theory_id
      
      values = {
        1=>IntrinsicRuntimeMethod.new,
        2=>IntrinsicTestCases.new,
        3=>IntrinsicLiteral.new(0),
        4=>IntrinsicLiteral.new(0),
        5=>IntrinsicLiteral.new(0),
        6=>IntrinsicLiteral.new(1)          
      }
      
      chains = chain.add_link(
        link_one,values
      )
      order = [head_id,link_one.theory_id,last_id]
      chain = chains.detect do |c|
        c.collect {|t| t.theory_id} == order
      end      
      
      chains = chain.add_link(
        link_two
      )
      order = [head_id,link_one.theory_id,link_two.theory_id,last_id]
      chain = chains.detect do |c|
        c.collect {|t| t.theory_id} == order
      end
      
      chains = chain.add_link(
        link_three
      )
      order = [head_id,link_one.theory_id,link_two.theory_id,link_three.theory_id,last_id]
      chain = chains.detect do |c|
        c.collect {|t| t.theory_id} == order
      end
      
      chains = chain.add_link(
        link_four,values
      )
      order = [head_id,link_one.theory_id,link_two.theory_id,link_three.theory_id,link_four.theory_id,last_id]
      chain = chains.detect do |c|
        c.collect {|t| t.theory_id} == order
      end
      
      #puts chain.describe
      # puts '----------------------'
      # puts chain.highlight_broken_links
      # puts chain.broken_link_count
      puts '============================================'      
      puts chain.complete?
      
      unified_chain = chain.unify_chain
      puts unified_chain.describe
      
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