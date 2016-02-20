require 'spec_helper'

module Cauldron
  
  describe ConcatOperator do 

    it_behaves_like "leaf_operator" do
      let(:leaf_operator) { ConcatOperator.new([0], 'foo') }
    end

    it_behaves_like "operator" do
      let(:operator) { ConcatOperator.new([0], 'foo') }
      let(:initial_scope) { Cauldron::Scope.new(['var0']) }
      let(:initial_operators) { [] }
    end        
    
    describe '.viable?' do

      context 'the arguments are not string' do

        it 'is false' do
          ConcatOperator.viable?([8], 'foobar').should be_false
        end

      end

      context 'the reponse is not a string' do

        it 'is false' do
          ConcatOperator.viable?(['foo'],8).should be_false
        end

      end

    end

    describe '.find_constants' do

      context 'argument is "foo"' do

        context 'response is "foobar"' do

          let(:problems) do
            Cauldron::ExampleSet.new(
              [Cauldron::Example.new({ arguments: ['foo'], response: 'foobar'})]
            )
          end          

          it 'return "[bar]"' do
            ConcatOperator.find_constants(problems).should == ['bar']
          end

        end

        context 'response is "barfoo"' do

          let(:problems) do
            Cauldron::ExampleSet.new(
              [Cauldron::Example.new({ arguments: ['foo'], response: 'barfoo'})]
            )
          end

          it 'returns "[]"' do
            ConcatOperator.find_constants(problems).should == []            
          end

        end

      end

    end

    describe '#successful?' do

      context 'all arguments end with "bar"' do

        it 'returns true' do
          problems = [
            {arguments: ['foo'], response: 'foobar'},
            {arguments: ['goo'], response: 'goobar'}
          ]          
          operator = ConcatOperator.new([],'bar')  
          problems.all? {|x| operator.successful?(x) }.should == true
        end

      end

    end

    describe '#to_ruby' do

      context 'using the constant "bar"' do

        let(:scope) { Cauldron::Scope.new(['var0']) }

        it 'returns "var0.concat("bar")"' do
          operator = ConcatOperator.new([0],'bar')
          operator.to_ruby(scope,[]).should == "var0.concat(\"bar\")"
        end

      end

    end

  end
  
end