require 'spec_helper'

module Cauldron
  
  describe Histories do

    describe '#insert_points' do

      context 'has history with point [0]' do

        let(:first_line_history) { Cauldron::History.new([{point: [0]}])}

        let(:subject){
          Cauldron::Histories.new([first_line_history])          
        }

        it 'returns [ [0] ]' do
          subject.insert_points.should == [[0]]
        end

      end

      context 'has history 2 points [1,0]' do

        let(:first_history) { Cauldron::History.new([{point: [1,0]}])}
        let(:second_history) { Cauldron::History.new([{point: [1,0]}])}

        let(:subject){
          Cauldron::Histories.new([first_history,second_history])          
        }        

        it 'returns 1 insert point' do
          subject.insert_points.should have(1).insert_point
        end

      end      

    end

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