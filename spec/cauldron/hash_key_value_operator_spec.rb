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

  end
  
end