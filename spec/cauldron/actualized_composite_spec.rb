require 'spec_helper'

module Cauldron

  describe ActualizedComposite do

    let(:empty_composite) do
      Cauldron::Solution::Composite.new([])
    end    

    describe '#histories' do

      context %q{there is one example "var0 = ['lion','bear']"} do

        let(:examples) do
          Cauldron::ExampleSet.new(
            [Cauldron::Example.new( {arguments: [['lion','bear']], response: 8} )]
          )
        end

        context 'composite is empty' do

          let(:subject) { Cauldron::ActualizedComposite.new(empty_composite, examples)}

          it 'returns 1 history' do
            subject.histories.length.should == 1
          end

          it 'history contains single log' do
            subject.histories.first.logs.length.should == 1
          end

        end

        context 'composite is "var0 = var1.collect { |var2|}' do

          let(:containing_statement) do
            StatementGenerator.new.build(['lion','bear'],[:collect]).first.init([0])
          end

          let(:composite) do
            Cauldron::Solution::Composite.new(
              [Tree::TreeNode.new("CHILD1", containing_statement )]
            )
          end

          let(:subject) { Cauldron::ActualizedComposite.new(composite, examples)} 

          log_history = %q{
            | {line: 2, depth: 1, total_line: 3, var0: ['lion', 'bear'], var2: 'lion', var1: nil} |
            | {line: 2, depth: 1, total_line: 3, var0: ['lion', 'bear'], var2: 'bear', var1: nil} |
            | {line: 3, depth: 0, total_line: 5, var0: ['lion', 'bear'], var1: ['lion', 'bear'] } |
          }

          it 'contains a history with 3 entries' do
            subject.histories.first.logs.length.should == 3
          end
          
          it %Q{retuns the following history: #{log_history} } do
            # logs = [
            #   {line: 0, depth: 1, var0: ['lion', 'bear'], var2: 'lion', var1: nil},
            #   {line: 0, depth: 1, var0: ['lion', 'bear'], var2: 'bear', var1: nil},
            #   {line: 1, depth: 0, var0: ['lion', 'bear'], var1: ['lion', 'bear'] }           
            # ]
            subject.histories.first.logs.should match_history(log_history)
            #logs.should match_history(log_history)
          end                 

        end

      end

    end

    describe '#extend_solution' do

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