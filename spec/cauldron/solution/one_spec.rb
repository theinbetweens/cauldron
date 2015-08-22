require 'spec_helper'

module Cauldron::Solution
  
  describe 'One' do 

    let(:solution) do
      Cauldron::Solution::One.new
    end
    
    describe '#to_ruby' do

      #it 'returns "var0.concat("bar")"' do
      it %q{returns var0.collect { |x| x * 2 } } do
          solution.to_ruby.to_s.should == %q{
var0.collect { |x| x * 2 }
}.strip
      end

    end

  end
  
end