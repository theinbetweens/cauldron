require 'spec_helper'

module Cauldron
  
  describe 'NumericOperator' do 
    
    describe '.viable?' do

      context 'consistent difference between argument and response' do

        it 'is true' do
          problem = [
            {arguments: [7], response: 8},
            {arguments: [10], response: 11}
          ]
          #NumericOperator.viable?(problem).should be_true
          problem.all? {|x| NumericOperator.viable?(x[:arguments], x[:response]) }.should be_true
        end

      end

      context 'arguments are not numeric' do

        it 'is false' do
          problem = [
            {arguments: ["ted"], response: 8},
            {arguments: ["ben"], response: 11}
          ]          
          #NumericValueRelationship.match?(problem).should be_false
          problem.all? {|x| NumericOperator.viable?(x[:arguments], x[:response]) }.should be_false
        end

      end

      context 'responses are not numeric' do

        it 'is false' do
          problem = [
            {arguments: [7], response: 'ben'},
            {arguments: [10], response: 'ted'}
          ]          
          #NumericValueRelationship.match?(problem).should be_false
          problem.all? {|x| NumericOperator.viable?(x[:arguments], x[:response]) }.should be_false
        end

      end

    end

    describe '#successful?' do

      context 'no consistent difference between values' do

        it 'is false' do
          problem = [
            {arguments: [7], response: 24},
            {arguments: [10], response: 11}
          ]          
          operator = NumericOperator.new(17)  
          #NumericValueRelationship.match?(problem).should be_false
          problem.all? {|x| operator.successful?(x) }.should be_false
        end

      end

    end

  end
  
end