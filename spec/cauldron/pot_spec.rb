require 'spec_helper'

module Cauldron
  
  describe 'Pot' do 
    
    describe '#load_theory' do
      
      it 'should be able to load theory' do
        pot = Pot.new
        pot.load_theory('example.yml').should == true
      end
      
    end
    
    describe '#generate' do
      
      it 'should return a runtime method' do
        pot = Pot.new
        pot.load_theory('example.yml')
        pot.generate("sparky","sparky").should == 
"""
def method_0(var_0)
  return var_0
end                  
"""
      end
      
      it "shouldn't generate a method if hasn't any theories loaded" do
        pot = Pot.new
        pot.generate([["sparky","sparky"],['kel','kel']]).should == "There aren't any theories loaded so Cauldron is unable to generate a solution"
      end
      
      
    end
    
  end
  
end