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

    describe '#insert_statement' do

      it 'should substitute function arguments for var1 syntax' do
        theory = Theory.new(
          [],
          { 'statement' => 'return x',
            'values' => {:x => 'ARG_1'},
            'position' => 'RUNTIME_METHOD.first.statement_id'
          },
          []
        )      
        theory.insert_statement.should == 'return var1'
      end

      it 'can generate a output return statement' do
        theory = Theory.new(
          [],
          { 'statement' => 'return x',
            'values' => {:x => 'OUTPUT'},
            'position' => 'RUNTIME_METHOD.first.statement_id'
          },
          []
        )      
        theory.insert_statement('sparky').should == %q{return 'sparky'}
      end

    end
    
  end
  
end
  