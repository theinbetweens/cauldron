require 'spec_helper'

module Cauldron
  
  describe 'Chain' do 
    
    describe '#complete?' do
      it 'chain is complete with just "return param1"' do
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
        chains = chain.add_link(head)
        chain = chains.first
        chains = chain.add_link(link_one)
        chain = chains.first
        chain.complete?.should == true        
      end
      it 'chain is complete with "if param1 == \'carrot\'"' do
        # => var1 = RuntimeMethod
        # => var2 = TestCases
        # => var3 => 0 context var1.params[var3]
        # => var4 => 0 context var2[var4]
        # => var5 => 0 context var2[x][:params][var5] 
        # => var6 => 0 context var2[var6]
        
        # => TODO This might duplicate demoes
        
        head_result = TheoryResult.new(StringToTheory.run(
            "if(var1.kind_of?(RuntimeMethod))\nreturn true\nend"
          )
        )
        head = Theory.new([],nil,[head_result])
        
        # => link #1
        link_one_dependent = TheoryDependent.new(StringToTheory.run(
            "if(var1.kind_of?(RuntimeMethod))\nreturn true\nend"
          )
        ) 
        link_one_action = TheoryAction.new(
          TheoryStatement.new(StringToTheory.run(
            'OpenStatement.new(If.new,Container.new(var1.params[var3],Equivalent.new,var2[var4][:params][var5]))')
          ),
          StringToTheory.run('var1.statement_id')
        )
        link_one_result = TheoryResult.new(StringToTheory.run(
          "if(var1.length == 1)\nreturn true\nend"
        ))
        link_one = Theory.new([link_one_dependent],link_one_action,[link_one_result])
        
        
        chain = Chain.new
        chains = chain.add_link(head)
        puts '-----------------------------::'
        puts chains.length    
        chain = chains.first
        
        head_id = chain.first.theory_id
        last_id = chain.last.theory_id
        puts 'Adding link -'
        puts link_one.describe
        chains = chain.add_link(link_one)
        puts '-----------------------------::'
        puts chains.length    
          
        # => Find the chan with link_one in the middle
        order = [head_id,link_one.theory_id,last_id]
        chain = chains.detect do |c|
          c.collect {|t| t.theory_id} == order
        end
        chain.complete?.should_not == true

        # =>
        link_two_dependent = TheoryDependent.new(StringToTheory.run(
          "if(var1.length == 1)\nreturn true\nend"
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
        link_two = Theory.new([link_two_dependent],link_two_action,[link_two_result])
        
        
        chains = chain.add_link(link_two)
        order = [head_id,link_one.theory_id,link_two.theory_id,last_id]
        chain = chains.detect do |c|
          c.collect {|t| t.theory_id} == order
        end
        puts '================================================'
        puts chain.describe
        chain.complete?.should_not == true
        
        # => Create the third action link
        link_three_dependent = TheoryDependent.new(StringToTheory.run(
          "if(var1.history(var2[var4][:params]) == var2[var4][:output])\nreturn true\nend"        
        ))                  
        link_three_action = TheoryAction.new(
          TheoryStatement.new(
            StringToTheory.run(
              'Statement.new(Return.new,var2[var6][:result])'  
            )
          ),
          StringToTheory.run('var4.statement_id')
        )
        link_three = Theory.new([link_three_dependent],link_three_action,[])                
        
        # => Add the link to the chain
        chains = chain.add_link(link_three)
        order = [head_id,link_one.theory_id,link_two.theory_id,link_three.theory_id,last_id]
        chain = chains.detect do |c|
          c.collect {|t| t.theory_id} == order
        end
        chain.complete?.should_not == true    
        
        # => Create the fourth action link
        link_four_result = TheoryResult.new(StringToTheory.run(
          "if(var1.all_pass?(var2))\nreturn true\nend"
        ))
        link_four = Theory.new([],nil,[link_four_result])
        
        chains = chain.add_link(link_four)
        order = [head_id,link_one.theory_id,link_two.theory_id,link_three.theory_id,link_four.theory_id,last_id]
        chain = chains.detect do |c|
          c.collect {|t| t.theory_id} == order
        end
        chain.complete?.should == true
        
        puts chain.describe
            
      end
    end
    
    describe '#unify_chain' do
      it 'can unify a chain with a "if statement in"' do
        head = Theory.new([],nil,[])
        link_one_action = TheoryAction.new(
          TheoryStatement.new(StringToTheory.run(
            'OpenStatement.new(If.new,Container.new(var1.params[var3],Equivalent.new,var2[var4][:params][var5]))')
          ),
          StringToTheory.run('var1.statement_id')
        )
        link_one = Theory.new([],link_one_action,[])
        chain = Chain.new
        chains = chain.add_link(head)    
        chain = chains.first
        head_id = chain.first.theory_id
        last_id = chain.last.theory_id
        chains = chain.add_link(link_one)
        order = [head_id,link_one.theory_id,last_id]
        chain = chains.detect do |c|
          c.collect {|t| t.theory_id} == order
        end              
        link_two_result = TheoryResult.new(StringToTheory.run(
          "if(var1.all_pass?(var2))\nreturn true\nend"
        ))
        link_two = Theory.new([],nil,[link_two_result])          
        chains = chain.add_link(link_two)
        order = [head_id,link_one.theory_id,link_two.theory_id,last_id]
        chain = chains.detect do |c|
          c.collect {|t| t.theory_id} == order
        end
        puts '-------------------------------************************'
        puts chain.unify_chain.describe
      end
    end
    
  end

end