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
          operator = NumericOperator.new([0],17)  
          #NumericValueRelationship.match?(problem).should be_false
          problem.all? {|x| operator.successful?(x) }.should be_false
        end

      end

    end

    describe '.instances' do

      let(:composite) do
        Cauldron::Solution::Composite.new([])
      end

      describe 'var0 needs to increase by 1' do

        let(:histories) do
          [
            Cauldron::History.new([{:var0=>7, :line=>0, :depth=>0, :total_line=>0}]),
            Cauldron::History.new([{:var0=>10, :line=>0, :depth=>0, :total_line=>0}])
          ]
        end

        let(:examples) do
          Cauldron::ExampleSet.new(
            [
              Cauldron::Example.new({arguments: [7], response: 8}),
              Cauldron::Example.new({arguments: [10], response: 11})
            ]
          )
        end

        it 'returns 1 composite' do
          NumericOperator.instances(histories, composite, examples).should have(1).composite
        end

      end

      describe 'var0 needs to increase by 2' do

        let(:histories) do
          [
            Cauldron::History.new([{:var0=>7, :line=>0, :depth=>0, :total_line=>0}]),
            Cauldron::History.new([{:var0=>10, :line=>0, :depth=>0, :total_line=>0}])
          ]
        end

        let(:examples) do
          Cauldron::ExampleSet.new(
            [
              Cauldron::Example.new({arguments: [7], response: 9}),
              Cauldron::Example.new({arguments: [10], response: 12})
            ]
          )
        end

        it 'returns 1 composite' do
          NumericOperator.instances(
            histories, composite, examples
          ).should have(1).composite
        end

        it 'looks like this:
def function(var0)
  var1 = var0+2
end
        ' do
            NumericOperator.instances(
              histories, composite, examples
            ).first.sexp(examples.variables).should match_code_of(%q{var0+2})
        end

      end      

    end

  end
  
end