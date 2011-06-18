require 'spec_helper'

module Cauldron
  
  describe 'Demos' do 
    
    describe '#demo_one' do
      it 'can generate a demo that can generate a simple runtime method' do
        temp = Object.new
        temp.extend(Cauldron::Demos)
        demo = temp.demo_one
        
        # => TODO Don't like this coupling
        Cauldron::Pot.new.demo_works?(demo).should == true
      end
    end

    describe '#demo_two' do
      it 'generates a demo that can return two different values' do
        temp = Object.new
        temp.extend(Cauldron::Demos)
        demo = temp.demo_two
        
        Cauldron::Pot.new.demo_works?(demo).should == true        
      end
    end
    
  end

end