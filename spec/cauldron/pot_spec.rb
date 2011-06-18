require 'spec_helper'

module Cauldron
  
  describe 'Pot' do 
    
    describe '#simmer' do
      it 'can simmer with demo one' do 
        pot = Cauldron::Pot.new
        lambda {pot.simmer(demo_one)}.should_not raise_error
      end
      it 'can simmer with demo two' do 
        
      end
    end
    
  end

end