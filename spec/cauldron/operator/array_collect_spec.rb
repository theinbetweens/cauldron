require 'spec_helper'

module Cauldron
  
  describe ArrayCollect do

    describe '#to_ruby' do

      it 'returns "var0.collect { |x| x }"' do
        operator = ArrayCollect.new
        operator.to_ruby.should == "var0.collect { |x| x }"
      end

      context 'passed "a * 2"' do

        it 'returns "var0.collect { |x| x * 2}"' do
          a_times_2 = StringAsteriskOperator.new(2)
          operator = ArrayCollect.new
          operator.to_ruby(a_times_2).should == 'var0.collect { |x| x * 2 }'
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
        ArrayCollect.new
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

  end

end