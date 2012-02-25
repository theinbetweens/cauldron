require 'spec_helper'

module Cauldron
  
  describe 'Pot' do 
    
    describe '#generate' do
      
      it 'should return a runtime method' do
        pot = Pot.new
        pot.generate("sparky","sparky").should == %q{
          def method_0(var_0)
            return var_0
          end          
        }  
      end
      
    end
    
  end
  
end