require 'spec_helper'

module Cauldron
  
  describe Histories do

    describe '#variable_permutations' do

      let(:histories) do
        Cauldron::Histories.new(
          [
            Cauldron::History.new([{var0: 4}])
          ]
        )
      end

      it 'returns []' do
        histories.variable_permutations(1).should == [
          {var0: 4}
        ]
      end

    end

  end

end