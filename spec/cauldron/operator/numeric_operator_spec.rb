require 'spec_helper'

module Cauldron
  
  describe 'NumericOperator' do

    it_behaves_like "operator" do
      let(:operator) { NumericOperator.new([0]) }
      let(:initial_scope) { Cauldron::Scope.new(['var0']) }
      let(:initial_operators) { [] }
    end    

    describe '#realizable?' do

      let(:subject) { NumericOperator.new([0]) }

      context 'histories is [[{:var0 => 8}]]' do

        let(:histories) do 
          Histories.new([Cauldron::History.new([{:var0 => 8}])])
        end

        before(:each) { histories.stub(:variable_permutations).and_return [{:var0 => 8}] }

        it 'returns true' do
          subject.realizable?(histories).should == true
        end

      end

      context %q{histories is [[{:var0 => 'string'}]]} do

        let(:histories) do 
          Histories.new([Cauldron::History.new([{:var0 => 'string'}])])
        end

        before(:each) { histories.stub(:variable_permutations).and_return [{:var0 => 'string'}] }

        it 'returns false' do
          subject.realizable?(histories).should == false
        end

      end      

    end
    
    describe '.viable?' do

      context 'consistent difference between argument and response' do

        it 'is true' do
          problem = [
            {arguments: [7], response: 8},
            {arguments: [10], response: 11}
          ]
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

        let(:problem) do
          [
            {arguments: [7], response: 24},
            {arguments: [10], response: 11}
          ]                    
        end

        let(:operator) { NumericOperator.new([0]) }

        it 'is false' do    
          problem.all? { |x| operator.successful?(x) }.should be_false
        end

      end

    end     

  end
  
end