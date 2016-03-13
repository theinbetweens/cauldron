require 'spec_helper'

module Cauldron

  describe ActualizedComposite do

    let(:empty_composite) do
      Cauldron::Solution::Composite.new([])
    end

    describe '#to_ruby' do

      let(:nested_statement) do
        Tree::TreeNode.new('x', StatementGenerator.new.build(['lion','bear'],[:collect], true).first.new([0]))
      end

      let(:composite) do
        chop = StatementGenerator.new.build('lion',[:chop]).first.new([2])
        nested_statement << Tree::TreeNode.new('x', chop)
        Cauldron::Solution::Composite.new([nested_statement])
      end

      let(:examples) do
        Cauldron::ExampleSet.new(
          [ Cauldron::Example.new(
              { arguments: [["lion", "bear"]], response: ["bea", "lio"]}
            )
          ]
        )        
      end

      let(:subject) do
        Cauldron::ActualizedComposite.new(
          composite, examples
        )
      end

      it 'prints the correct statement' do
        subject.to_ruby.should == %q{var1 = var0.collect do |var2| var2.chop end}
      end

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
            StatementGenerator.new.build(['lion','bear'],[:collect]).first.new([0])
          end

          let(:composite) do
            Cauldron::Solution::Composite.new(
              [Tree::TreeNode.new("CHILD1", containing_statement )]
            )
          end

          let(:subject) { Cauldron::ActualizedComposite.new(composite, examples)} 

          # TODO total_line is going to be wrong
          log_history = %q{
            | {line: 0, depth: 1, total_line: 3, point: [0,0], var0: ['lion', 'bear'], var2: 'lion', var1: nil} |
            | {line: 0, depth: 1, total_line: 3, point: [0,0], var0: ['lion', 'bear'], var2: 'bear', var1: nil} |
            | {line: 0, depth: 0, total_line: 4, point: [1], var0: ['lion', 'bear'], var1: ['lion', 'bear'] } |
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