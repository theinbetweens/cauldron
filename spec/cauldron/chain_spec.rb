require 'spec_helper'

module Cauldron
  
  describe 'Chain' do 
    
    describe '#complete?' do
      it 'chain is complete with just "return param1"' do        
        temp = Object.new
        temp.extend(Cauldron::Demos)
        demo = temp.demo_one
        demo[:chain].complete?.should == true
      end
      it 'chain is complete with "if param1 == \'carrot\'"' do        
        temp = Object.new
        temp.extend(Cauldron::Demos)
        demo = temp.demo_two
        demo[:chain].complete?.should == true        
      end
    end
    
  end

end