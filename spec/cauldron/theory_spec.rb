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

    describe '#generate_function' do

      it 'can add a basic return statement to a function' do

        a = Theory.new(
          [],
          {:statement => 
              'return x',
              :values => {:x => 'ARG_1'},
              :position => 'RUNTIME_METHOD.first.statement_id'
          },
          []
        )
        empty_function = %q{
          def extend_function_test_method(var1)
          end
        }
        empty_function.apply_theory(a).write.should == %q{
          def extend_function_test_method(var1)
            return var1
          end          
        }
      end

    end

    describe '#insert_statement' do

      it 'should should substitute function arguments for var1 syntax' do
        theory = Theory.new(
          [],
          {:statement => 
              'return x',
              :values => {:x => 'ARG_1'},
              :position => 'RUNTIME_METHOD.first.statement_id'
          },
          []
        )      
        theory.insert_statement.should == 'return var1'
      end

    end
    
  end
  
end
  