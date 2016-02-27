require 'spec_helper'

module Cauldron
  
  describe 'NumericOperator' do

    it_behaves_like "operator" do
      let(:operator) { NumericOperator.new([0], 4) }
      let(:initial_scope) { Cauldron::Scope.new(['var0']) }
      let(:initial_operators) { [] }
    end    

    describe '#realizable?' do

      let(:subject) { NumericOperator.init([0], 4) }

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

        let(:problem) do
          [
            {arguments: [7], response: 24},
            {arguments: [10], response: 11}
          ]                    
        end

        let(:operator) { NumericOperator.new([0],17) }

        it 'is false' do    
          problem.all? { |x| operator.successful?(x) }.should be_false
        end

      end

    end

    describe '#instances' do

      let(:composite) do
        Cauldron::Solution::Composite.new([])
      end

      describe 'var0 needs to increase by 1' do

        let(:histories) do
          Cauldron::Histories.new([
              Cauldron::History.new([{:var0=>7, :line=>0, :depth=>0, :total_line=>0}]),
              Cauldron::History.new([{:var0=>10, :line=>0, :depth=>0, :total_line=>0}])
            ]
          )
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
          NumericOperator.instances(histories, composite, examples, [0,0]).should have(1).composite
        end

      end

      describe 'var0 needs to increase by 2' do

        let(:histories) do
          Cauldron::Histories.new(
            [
              Cauldron::History.new([{:var0=>7, :line=>0, :depth=>0, :total_line=>0, :point => [0] }]),
              Cauldron::History.new([{:var0=>10, :line=>0, :depth=>0, :total_line=>0, :point => [0]}])
            ]            
          )
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
            histories, composite, examples, [0,0]
          ).should have(1).composite
        end

        it 'looks like this:
def function(var0)
  var1 = var0+2
end
        ' do
            NumericOperator.instances(
              histories, composite, examples, [0,0]
            ).first.to_sexp(examples.variables, []).should match_code_of(%q{var0+2})
        end

      end      

    end

  end
  
end