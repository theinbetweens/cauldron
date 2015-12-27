require 'spec_helper'

module Cauldron

  describe ActualizedComposite do

    describe '#extend_solution' do

      let(:empty_composite) do
        Cauldron::Solution::Composite.new([])
      end

      let(:examples) do
        Cauldron::ExampleSet.new(
          [
            Cauldron::Example.new( {arguments: [7], response: 8} ),
            Cauldron::Example.new( {arguments: [10], response: 11} )
          ]
        )
      end

      let(:subject) { Cauldron::ActualizedComposite.new(empty_composite, examples)}

      context 'there is only the numeric operator available' do

        before(:each) do
          Builder.stub(:available_statement_types).and_return [NumericOperator]
        end

        it 'returns 1 actualized composite' do
          subject.extend_solution.should have(1).composite
        end

      end

    end

  end

end