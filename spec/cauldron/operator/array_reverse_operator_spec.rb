require 'spec_helper'

module Cauldron
  
  describe 'ArrayReverseOperator' do

    it_behaves_like "operator" do
      let(:operator) { ArrayReverseOperator.new([0]) }
      let(:initial_scope) { Cauldron::Scope.new(['var0']) }
      let(:initial_operators) { [] }
    end    

    describe '.viable?' do

      context 'the arguments are not arrays' do

        it 'is false' do
          expect(ArrayReverseOperator.viable?([8], ['lions','tigers','bears'])).to eql(false)
        end

      end

      context 'using more than 1 argument' do

        it 'is false' do
          expect(ArrayReverseOperator.viable?([['lions'],['tigers']], ['lions','tigers'])).to eql(false)
        end

      end

      context 'response is not an array' do

        it 'is false' do
          expect(ArrayReverseOperator.viable?([['lions','tigers']], 'lions')).to eql(false)
        end

      end      

    end

    describe '#successful?' do

      context 'using array that needs reversed' do

        it 'is true' do
          operator = ArrayReverseOperator.new([0])
          expect(
            operator.successful?(
              { arguments: [['lions','tigers']],response: ['tigers','lions']}
            )
          ).to eql(true)
        end

      end

      context "using array that can't be reversed" do

        it 'is false' do
          operator = ArrayReverseOperator.new([0])
          expect(
            operator.successful?(
              {arguments:[['lions','tigers']],response: ['lions','tigers']}
            )
          ).to eql(false)
        end
        
      end

    end

  end

end