require 'spec_helper'

module Cauldron
  
  describe 'Theory' do 
    
    describe '#==' do
      
      it 'theories are equal if the they have the same dependents' do
        a = Theory.new(
          [
            "if ARG_1 == OUTPUT
              return true
            end"                        
          ],
          {:statement => 'return x',:values => {:x => 'ARG_1'},:position => 'RUNTIME_METHOD.first.statement_id'},
          ['RUNTIME_METHOD.all_pass(ARG_1)']
        )
        b = Theory.new(
          [
            "if ARG_1 == OUTPUT
              return true
            end"                        
          ],
          {:statement => 'return x',:values => {:x => 'ARG_1'},:position => 'RUNTIME_METHOD.first.statement_id'},
          ['RUNTIME_METHOD.all_pass(ARG_1)']
        )
        a.should == b        
        
      end
      
    end
    
  end
  
end
  