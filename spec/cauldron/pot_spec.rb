require 'spec_helper'

module Cauldron
  
  describe 'Pot' do

    let(:collect_and_multiple) do
      [
        { arguments: [['foo','lima']], response: ['foofoo','limalima'] },
        { arguments: [['bar','delta']], response: ['barbar','deltadelta'] }
      ]      
    end

    describe '#solve' do

      context 'passed simple if statement problem' do

        it 'returns a valid statement' do
          pot = Pot.new
          pot.solve(
            [
              {arguments: [7], response: 'seven'},
              {arguments: [8], response: 'eight'}
            ]
          ).should == 
%q{
def function(var0)
  if var0 == 7
    return "seven"
  end
  if var0 == 8
    return "eight"
  end
end
}.lstrip
        end

      end

      context 'passed +1 problem' do

        it 'returns a function that adds 1 to total' do
          pot = Pot.new
          pot.solve(
            [
              {arguments: [7], response: 8},
              {arguments: [10], response: 11}
            ]
          ).should == 
%q{
def function(var0)
  var0 + 1
end
}.lstrip
        end

      end

      context 'passed "foo" and return "foobar"' do

        it 'returns a concat function' do
          pot = Pot.new
          pot.solve(
            [
              {arguments: ['foo'], response: 'foobar'},
              {arguments: ['bar'], response: 'barbar'}
            ]
          ).should == 
%q{
def function(var0)
  var0.concat("bar")
end
}.lstrip
        end

      end

      context 'passed ["lion","bear"] and return ["bear","lion"]' do       

        it 'returns a reverse function' do
          pot = Pot.new
          pot.solve(
            [
              { arguments: [['lion', 'bear']], response: ['bear','lion'] },
              { arguments: [['foo', 'bar']], response: ['bar','foo'] }
            ]
          ).should == 
%q{
def function(var0)
  var0.reverse
end
}.lstrip
        end

      end

      context '{:foo => 5, :bar => 7 } and return 7' do

        context '{:foo => 10, :bar => 5 } and return 10' do

          let(:pot) { Pot.new }

          it 'returns the value of foo' do
            pot.solve(
              [
                { arguments: [{:foo => 5, :bar => 7 }], response: 5 },
                { arguments: [{:foo => 10, :bar => 5 }], response: 10 }
              ]
            ).should == 
%q{
def function(var0)
  var0[:foo]
end
}.lstrip
          end

        end

      end

      describe 'using string#* problem' do

        it 'returns a valid statement' do
          sexp = Ripper::SexpBuilder.new(%Q{def function(var0)\n  var0 * 3\nend}).parse
          pot = Pot.new
          pot.solve(
            [
              {arguments: ['foo'], response: 'foofoofoo'},
              {arguments: ['bar'], response: 'barbarbar'}
            ]
          ).should == 
%q{
def function(var0)
  var0 * 3
end
}.lstrip
        end

      end

      describe 'chaining operators' do

        describe 'use of Array#collect' do

          describe 'use of string#*' do

            it %{returns the function
def function(var0)
  var0.collect { |x| x * 2 }
end
              } do
              pot = Pot.new
              pot.solve(
                [
                  { arguments: [['foo', 'lima']], response: ['foofoo', 'limalima'] },
                  { arguments: [['bar', 'delta']], response: ['barbar', 'deltadelta'] }
                ]
              ).should == 
%q{
def function(var0)
  var0.collect { |x|
    x * 2
  }
end
}.lstrip
            end

          end

        end

      end 

    end

    describe '#viable_double_operators' do

      context 'using the foo*2 problem' do

        let(:problems) do
          Cauldron::ExampleSet.new(
            [
              Cauldron::Example.new({ arguments: [['foo','lima']], response: ['foofoo','limalima'] }),
              Cauldron::Example.new({ arguments: [['bar','delta']], response: ['barbar','deltadelta'] }),
            ]
          )
        end        

        it 'returns Array#collect and String#*' do
          pending
          pot = Pot.new
          pot.viable_double_operators(
            problems
          ).to_set.should == [
            [ArrayCollect, ConcatOperator],[ArrayCollect, StringAsteriskOperator]
          ].to_set
        end

      end

    end

    describe '#chain_operators' do

      it 'returns a solution function' do
        pot = Pot.new
        pot.chain_operators(
          collect_and_multiple,
          [ArrayCollect.new([0]), StringAsteriskOperator.new([1], 2)]
        ).should == "var0.collect { |var1| var1 * 2 }"
      end

    end

    describe '#single_viable_operators' do

      context 'argument is ["a","b","c"]' do

        context 'response is ["a","b","c"]' do

          let(:problems) do
            Cauldron::ExampleSet.new(
              [
                Cauldron::Example.new({ arguments: [['a','b','c']], response: ['a','b','c']})
              ]
            )
          end          

          it 'response contains "ArrayCollect" class' do
            pot = Pot.new
            pot.single_viable_operators(
              problems
            ).should include(ArrayCollect)
          end

        end

      end

    end

    describe '#build_chain_operator' do

      #[ArrayCollect, StringAsteriskOperator]
      context 'operators are Array#collect and String#*' do

        let(:scope) do
          Cauldron::Scope.new(['var0'])
        end

        let(:tree) do
          root = Tree::TreeNode.new("ROOT", "Root Content")
          child = Tree::TreeNode.new("CHILD1", ArrayCollect.new([0])) 
          grand_child = Tree::TreeNode.new("CHILD2", StringAsteriskOperator.new([1],2))
          child << grand_child
          root << child
          root
        end        

        it 'is "var0.collect { |x| x * 2 }"' do
          pot = Pot.new
          pot.build_chain_operator(
            [ArrayCollect, StringAsteriskOperator],
            collect_and_multiple
          ).to_ruby(scope).should == Cauldron::Solution::Composite.new(
            tree.children #[ArrayCollect.new([0]),StringAsteriskOperator.new([1],2)]
          ).to_ruby(Cauldron::Scope.new(['var0']))
        end

      end
 
    end
    
  end
  
end