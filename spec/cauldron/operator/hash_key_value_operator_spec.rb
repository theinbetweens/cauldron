require 'spec_helper'

module Cauldron
  
  describe HashKeyValueOperator do 

    it_behaves_like "operator" do
      let(:operator) { HashKeyValueOperator.new([0]) }
      let(:initial_scope) { Cauldron::Scope.new(['var0']) }
      let(:initial_operators) { [] }
    end      
    
    describe '.viable?' do

      context 'the argument is not a hash' do

        it 'is false' do
          expect(HashKeyValueOperator.viable?(['string'], 'foobar')).to eql(false)
        end

      end

      context 'the argument is a hash' do

        it 'is true' do
          expect(HashKeyValueOperator.viable?([{:foo => 'bar'}], 'foobar')).to eql(true)
        end

      end

    end

    describe '.uses_constants?' do

      it 'is true' do
        expect(HashKeyValueOperator.uses_constants?).to eql(true)
      end

    end

    describe '.find_constants' do

      context 'hash uses key :foo' do

        let(:problems) do
          Cauldron::ExampleSet.new(
            [Cauldron::Example.new({ arguments: [{:foo => 'bar'}], response: 'bar'})]
          )
        end         

        it 'return ":foo"' do
          HashKeyValueOperator.find_constants(problems).should == [:foo]
        end

      end

    end

    describe '#successful?' do

      context 'both problems return reponse when using the key' do

        let(:problems) do
          Cauldron::ExampleSet.new(
            [
              Cauldron::Example.new({ arguments: [{:foo => 'bar'}], response: 'bar'}),
              Cauldron::Example.new({ arguments: [{:foo => 'mass', :bar => 'effect'}], response: 'mass'}),
            ]
          )
        end        

        it 'is true' do
          operator = HashKeyValueOperator.new([0])  
          problems.all? {|x| operator.successful?(x) }.should == true
        end

      end

    end

    describe '#to_ruby' do

      let(:scope) { Cauldron::Scope.new(['var0']) }

      context 'using the constant ":foo"' do

        it 'returns "var0[:foo]"' do
          operator = HashKeyValueOperator.new([0])
          operator.to_ruby(scope,[]).should == 'var0[:foo]'
        end

      end

    end

  end
  
end