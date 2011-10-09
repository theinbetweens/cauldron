require 'spec_helper'

module Cauldron
  
  describe 'Theory' do 
    
    describe '#map_to' do
      it 'can map a simple theory to new values' do
        link_one_action = TheoryAction.new(
          TheoryStatement.new(StringToTheory.run('Statement.new(Return.new,var2.params[var3])')),
          StringToTheory.run('var1.statement_id')
        )
        link_one_result = TheoryResult.new(StringToTheory.run("if(var1.all_pass?(var2))\nreturn true\nend"))
        theory = Theory.new([],link_one_action,[link_one_result])        
        
        # Create the mapping for the theory
        mapping = Mapping.new({
          1=>IntrinsicRuntimeMethod.new,
          2=>IntrinsicTestCases.new,
          3=>IntrinsicLiteral.new(0)
        })
        # => TODO Why doesn't the tab character appear - or appear as a space
        result = " 
if: 

action: 
  runtime_method.add_statement_at(Statement.new(Return.new, test_cases.params[0]),runtime_method.statement_id)
result: 
  if(runtime_method.all_pass?(test_cases))
    return true
  end
"
        theory.map_to(mapping).write.strip.should == result.strip
        
      end
      it 'can map a theory with an if statement' do 
        
        link_one_action = TheoryAction.new(
          TheoryStatement.new(StringToTheory.run(
            'OpenStatement.new(If.new,Container.new(var1.params[var3],Equivalent.new,var2[var4][:params][var5]))')
          ),
          StringToTheory.run('var1.statement_id')
        )
        theory = Theory.new([],link_one_action,[])
        mapping = Mapping.new({
          1=>IntrinsicRuntimeMethod.new,
          2=>IntrinsicTestCases.new,
          3=>IntrinsicLiteral.new(0),
          4=>IntrinsicLiteral.new(0),
          5=>IntrinsicLiteral.new(0)
        })        
        puts theory.map_to(mapping).describe        
        
      end
    end
    
  end

end