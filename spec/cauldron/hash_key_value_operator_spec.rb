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

        it 'return ":foo"' do
          problems = [
            { arguments: [{:foo => 'bar'}], response: 'bar'}
          ]
          HashKeyValueOperator.find_constants(problems).should == [:foo]
        end

      end

    end

    describe '#successful?' do

      context 'both problems return reponse when using the key' do

        it 'is true' do
          problems = [
            { arguments: [{:foo => 'bar'}], response: 'bar'},
            { arguments: [{:foo => 'mass', :bar => 'effect'}], response: 'mass'}
          ]
          operator = HashKeyValueOperator.new([0],:foo)  
          problems.all? {|x| operator.successful?(x) }.should == true
        end

      end

    end

    describe '#to_ruby' do

      context 'using the constant ":foo"' do

        it 'returns "var0[:foo]"' do
          operator = HashKeyValueOperator.new([0],:foo)
          operator.to_ruby(['var0']).should == '  var0[:foo]'+"\n"
        end

      end

      context 'using the constant "foo"' do

        it "returns 'var0['foo']" do
          operator = HashKeyValueOperator.new([0],'foo')
          operator.to_ruby(['var0']).should == "  var0['foo']"+"\n"
        end

      end

    end

    describe '#build' do

      
      
    end

  end
  
end