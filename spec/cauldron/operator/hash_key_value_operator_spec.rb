require 'spec_helper'

module Cauldron
  
  describe 'HashKeyValueOperator' do 
    
    describe '.viable?' do

      context 'the argument is not a hash' do

        it 'is false' do
          HashKeyValueOperator.viable?(['string'], 'foobar').should be_false
        end

      end

      context 'the argument is a hash' do

        it 'is true' do
          HashKeyValueOperator.viable?([{:foo => 'bar'}], 'foobar').should be_true
        end

      end

    end

    describe '.uses_constants?' do

      it 'is true' do
        HashKeyValueOperator.uses_constants?.should be_true
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
          operator = HashKeyValueOperator.new([0],:foo)  
          problems.all? {|x| operator.successful?(x) }.should == true
        end

      end

    end

    describe '#to_ruby' do

      let(:scope) { Cauldron::Scope.new(['var0']) }

      context 'using the constant ":foo"' do

        it 'returns "var0[:foo]"' do
          operator = HashKeyValueOperator.new([0],:foo)
          operator.to_ruby([],scope).should == 'var0[:foo]'
        end

      end

      context 'using the constant "foo"' do

        it "returns 'var0['foo']" do
          operator = HashKeyValueOperator.new([0],'foo')
          operator.to_ruby([], scope).should == "var0[\"foo\"]"
        end

      end

    end

    describe '#build' do

      
      
    end

  end
  
end