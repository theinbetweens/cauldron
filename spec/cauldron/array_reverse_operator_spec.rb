require 'spec_helper'

module Cauldron
  
  describe 'ArrayReverseOperator' do

    describe '.viable?' do

      context 'the arguments are not arrays' do

        it 'is false' do
          ArrayReverseOperator.viable?([8], ['lions','tigers','bears']).should be_false
        end

      end

      context 'using more than 1 argument' do

        it 'is false' do
          ArrayReverseOperator.viable?([['lions'],['tigers']], ['lions','tigers']).should be_false
        end

      end

      context 'response is not an array' do

        it 'is false' do
          ArrayReverseOperator.viable?([['lions','tigers']], 'lions').should be_false
        end

      end      

    end

  end

end