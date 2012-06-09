require 'spec_helper'

module Cauldron
  
  describe 'Function' do 
    
    describe '#apply_theory' do

      it 'extends the function when the theory is applied' do

        function = Function.new
        theory = Theory.new(
          [],
          {:statement => 
              'return x',
              :values => {:x => 'ARG_1'},
              :position => 'RUNTIME_METHOD.first.statement_id'
          },
          []
        )      
        theory.stub!(:insert_statement).and_return('return var1')
        function.apply_theory(theory).write.gsub(/\s/,'').should == %q{
          def extend_function_test_method(var1)
            return var1
          end           
        }.gsub(/\s/,'')
        
      end

    end

    describe '#write' do

      it 'should print out an empty statement' do
        Function.new.write.gsub(/\s/,'').should == %q{
          def extend_function_test_method(var1)
            #donothing
          end
        }.gsub(/\s/,'')
      end

    end
    
  end
  
end