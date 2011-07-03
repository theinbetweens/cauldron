require 'spec_helper'

module Cauldron
  
  describe 'TheoryAction' do
    
    describe '#statements_with_variable' do
      
      it 'should return two statements for the action "Statement.new(Return.new, var0.params[var2]),var0.statement_id"' do
        link_one_action = TheoryAction.new(
          TheoryStatement.new(StringToTheory.run('Statement.new(Return.new,var1.params[var3])')),
          StringToTheory.run('var1.statement_id')
        )
        link_one_action.statements_with_variable(1).length.should == 3
        res = link_one_action.statements_with_variable(1).collect {|x| x.write }
        res.should include('var1.statement_id')
        res.should include('var1.params') 
        
      end
      
    end
    
  end
  
end