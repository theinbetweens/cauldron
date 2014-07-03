require 'spec_helper'

module Cauldron
  
  describe 'ArrayCollect' do

    describe '#to_ruby' do

      it 'returns "var0.collect { |x| x }"' do
        operator = ArrayCollect.new
        operator.to_ruby.should == "  var0.collect { |x| x }"
      end

      context 'passed "a * 2"' do

        it 'returns "var0.collect { |x| x * 2}"' do
          a_times_2 = StringAsteriskOperator.new(2)
          operator = ArrayCollect.new
          operator.to_ruby(a_times_2).should == '  var0.collect { |x| x * 2 }'+"\n"
        end

      end

    end

  end

end