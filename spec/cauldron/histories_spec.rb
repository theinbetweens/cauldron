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

    describe '#contexts_at' do

    # #<Cauldron::Histories:0x007f7f5c3f38c8
    #  @results=
    #   [#<Cauldron::History:0x007f7f5c3f3940
    #     @logs=
    #      [{:var2=>"Sparky", :var0=>["Sparky", "Kels"], :var1=>nil, :line=>0, :depth=>1, :total_line=>3, :point=>[0, 0]},
    #       {:var2=>"Kels", :var0=>["Sparky", "Kels"], :var1=>nil, :line=>0, :depth=>1, :total_line=>3, :point=>[0, 0]},
    #       {:var0=>["Sparky", "Kels"], :var1=>["Sparky", "Kels"], :line=>0, :depth=>0, :total_line=>4, :point=>[1]}]>]>      

      # point [0,0] => [{:var2=>"Sparky", :var0=>["Sparky", "Kels"], :var1=>nil}]
      # point [0,0] => [{:var2=>"Kels", :var0=>["Sparky", "Kels"], :var1=>nil}]
      # point [1] => [{:var2=>"Kels", :var0=>["Sparky", "Kels"], :var1=>nil}]

      let(:histories) do
        Cauldron::Histories.new(
          [
            Cauldron::History.new(
              [
                {:var2=>"Sparky", :var0=>["Sparky", "Kels"], :var1=>nil, :line=>0, :depth=>1, :total_line=>3, :point=>[0, 0]},
                {:var2=>"Kels", :var0=>["Sparky", "Kels"], :var1=>nil, :line=>0, :depth=>1, :total_line=>3, :point=>[0, 0]},
                {:var0=>["Sparky", "Kels"], :var1=>["Sparky", "Kels"], :line=>0, :depth=>0, :total_line=>4, :point=>[1]}
              ]
            )
          ]
        )
      end

      it 'returns 1 context' do
        histories.contexts_at([1]).should have(1).context
      end

      it 'returns 2 contexts' do
        histories.contexts_at([0, 0]).should have(2).contexts
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