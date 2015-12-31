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

      it 'returns [{var0: 4}]' do
        histories.variable_permutations(1).should == [
          {var0: 4}
        ]
      end

      context 'when var0 is ["Sparky", "Kel"]' do

        let(:histories) do
          Cauldron::Histories.new(
            [
              Cauldron::History.new([{:var0=>["Sparky", "Kel"], :line=>0, :depth=>0, :total_line=>0}])
            ]
          )
        end

        it 'returns ["Sparky", "Kel"]' do
          histories.variable_permutations(1).should == [
            {var0: ["Sparky", "Kel"]}
          ]
        end        

      end

      context 'using two histories' do

        let(:histories) do
          Cauldron::Histories.new(
            [
              Cauldron::History.new([{:var0=>"Sparky", :line=>0, :depth=>0, :total_line=>0}]),
              Cauldron::History.new([{:var0=>"Kel", :line=>0, :depth=>0, :total_line=>0}])
            ]
          )
        end

        it 'returns []' do
          histories.variable_permutations(1).should == [
            {var0: 'Sparky'}, {var0: 'Kel'}
          ]
        end              

      end

    end

  end

end