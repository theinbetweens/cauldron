require 'spec_helper'

module Cauldron
  
  describe ArrayCollect do

    it_behaves_like "operator" do
      let(:operator) { ArrayCollect.new([0]) }
      let(:initial_scope) { Cauldron::Scope.new(['var0']) }
      let(:initial_operators) { [] }
    end    

    describe '.instances' do

      let(:composite) do
        Cauldron::Solution::Composite.new([])
      end      

      context 'histories [[{:var0=>["Sparky", "Kel"], :line=>0, :depth=>0, :total_line=>0}]]' do

        let(:histories) do
          [
            History.new(
              [{:var0=>["Sparky", "Kel"], :line=>0, :depth=>0, :total_line=>0}]
            )
          ]
        end

        let(:examples) do
          Cauldron::ExampleSet.new(
            [
              Cauldron::Example.new({arguments: [["Sparky", "Kel"]], response: ["Spark", "Ke"]})
            ]
          )
        end

        it 'returns an instance of Composite' do
          ArrayCollect.instances(
            histories,composite,examples, [[0,0]]
          ).first.class == Cauldron::Solution::Composite
        end

      end

      context 'histories [[{:var0=>"Sparky", :line=>0, :depth=>0, :total_line=>0}]]' do

        let(:histories) do
          [
            History.new(
              [{:var0=>"Sparky", :line=>0, :depth=>0, :total_line=>0}]
            )
          ]
        end

        let(:examples) do
          Cauldron::ExampleSet.new(
            [
              Cauldron::Example.new({arguments: ["Sparky"], response: ["Spark"]})
            ]
          )
        end        

        it "doesn't return any instances of ArrayCollect" do
          ArrayCollect.instances(histories,composite,examples, [0,0]).should be_empty
        end

      end      

    end

    describe '#context_history' do

      context 'using ["lions", "bears"]' do

        let(:instance) { ArrayCollect.new([0]) }

        it "is [{x: 'lions'},{x: 'bears'}]" do
          instance.context_history(
            ['var0'],['lions','bears']
          ).should == [{x: 'lions'},{x: 'bears'}]
        end

      end

    end

    describe '#to_ruby' do

      let(:scope) { Cauldron::Scope.new(['var0']) }     

      it 'returns "var0.collect { |x| x }"' do
        operator = ArrayCollect.new([0])
        operator.to_ruby(scope,[]).should == "var0.collect { |var1| }"
      end

      context 'passed "a * 2"' do

        let(:string_asterisk) do
          Tree::TreeNode.new("CHILD1", StringAsteriskOperator.new([1],2))
        end

        it 'returns "var0.collect { |var1| var1 * 2}"' do
          operator = ArrayCollect.new([0])
          operator.to_ruby(
            scope, [string_asterisk]
          ).should == 'var0.collect { |var1| var1 * 2 }'
        end

      end

    end

    describe '#==' do

      describe 'ArrayCollect.new([0]) == ArrayCollect.new([0])' do

        it 'is true' do
          ArrayCollect.new([0]).should == ArrayCollect.new([0])
        end        

      end

      describe 'ArrayCollect.new([0]) == ArrayCollect.new([1])' do

        it 'is false' do
          ArrayCollect.new([0]).should_not == ArrayCollect.new([1])
        end        

      end      

    end

    describe '.viable?' do

      context 'argument is an array' do

        it 'is true' do
          arg = []
          ArrayCollect.viable?( [arg], [] ).should be_true
        end

      end

    end

    describe '#successful?' do

      let(:first_argument) do
        ['a','b','c']
      end

      let(:bad_response) do
        ['a','b','d']
      end

      let(:operator) do
        ArrayCollect.new([0])
      end

      it 'is true' do
        problem = {arguments: [first_argument], response: ['a','b','c']}
        operator.successful?(problem).should == true
      end

      it 'is true' do
        problem = {arguments: [first_argument], response: bad_response}
        operator.successful?(problem).should be_false
      end      

    end

    describe '.step_problems' do

      context 'using arguments "["foo","lima"]" and "["bar","delta"]"' do

        let(:problem) do
          #Cauldron::ExampleSet.new(
            #[Cauldron::Example.new({ arguments: [['foo','lima']], response: ['foofoo','limalima']})]
            Cauldron::Example.new({ arguments: [['foo','lima']], response: ['foofoo','limalima']})
          #)
        end        

        it 'returns arguments "["foo","lima"]" and "["bar","delta"]"' do
          #ArrayCollect.step_problems(
          # Maybe blockify would be more appropriate
          ArrayCollect.step_problem(
            #[
              #{ arguments: [['foo','lima']], response: ['foofoo','limalima'] }#,
              #{ arguments: [['bar','delta']], response: ['barbar','deltadelta'] }
            #]   
            problem         
          ).should == [
            { arguments: ['foo'], response: 'foofoo' },
            { arguments: ['lima'], response: 'limalima' }
          ]     
        end

      end

    end

  end

end