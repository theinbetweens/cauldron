require 'spec_helper'

module Cauldron
  
  describe 'Pot' do

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
    return 'seven'
  end
  if var0 == 8
    return 'eight'
  end
end  
}.strip
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
}.strip          
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
  var0.concat('bar')
end
}.strip          
        end

      end

    end
    
  end
  
end