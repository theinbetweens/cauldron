require 'spec_helper'

module Cauldron
  
  describe 'IfRelationship' do 
    
    describe '.match?' do

      context 'any valid collection of problems' do

        it 'is true' do
          problem = [
            {arguments: [7], response: 'seven'},
            {arguments: [8], response: 'eight'}
          ]          
          IfRelationship.match?(problem).should be_true
        end

      end

    end

  end
  
end