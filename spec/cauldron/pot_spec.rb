require 'spec_helper'

module Cauldron
  
  describe 'Pot' do 
    
    describe '#simmer' do
      it 'can simmer with demo one' do 
        pot = Cauldron::Pot.new
        pot.clear
        lambda {pot.simmer(demo_one)}.should_not raise_error
      end
      it 'can simmer with demo two' do 
        pot = Cauldron::Pot.new        
      end
    end
    
    describe '#brew' do
      it 'can come up with a solution after it has been given demo_one' do
        pot = Cauldron::Pot.new
        pot.clear
        pot.simmer(demo_one)
        cases = []
        cases << convert_to_example(separate_values("'sparky','sparky'"))
        cases << convert_to_example(separate_values("'kel','kel'"))
        pot.brew(cases)
      end
      
      it 'can come up with a solution that fits demo two' do
        pot = Cauldron::Pot.new
        pot.clear
        pot.simmer(demo_two)
      end
      
    end
    
  end

end