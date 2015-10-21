require 'spec_helper'

module Cauldron
  
  describe ConcatOperator do 
    
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

          it 'return "[bar]"' do
            problems = [
              { arguments: ['foo'], response: 'foobar'}
            ]
            ConcatOperator.find_constants(problems).should == ['bar']
          end

        end

        context 'response is "barfoo"' do

          it 'returns "[]"' do
            problems = [
              { arguments: ['foo'], response: 'barfoo'}
            ]
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

        it 'returns "var0.concat("bar")"' do
          operator = ConcatOperator.new([],'bar')
          operator.to_ruby.should == "var0.concat(\"bar\")"
        end

      end

    end

  end
  
end