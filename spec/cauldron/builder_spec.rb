require 'spec_helper'

module Cauldron
  
  describe 'Builder' do

    describe '#insert_points' do

      let(:builder) { Cauldron::Builder.new(composite) }

      context 'empty method' do

        let(:composite) do
          Cauldron::Solution::Composite.new()
        end        

        it 'has 1' do
          builder.insert_points.length.should == 1
        end

        it 'is line 0 depth 0' do
          builder.insert_points.first.should == [0,0]
        end

      end

      context 'has line "var0 = 5"' do

        let(:composite) do
          Cauldron::Solution::Composite.new( [NumericOperator.new([0],4)] )
        end

        it 'has 1' do
          builder.insert_points.length.should == 1
        end

        it 'is line 1 depth 0' do
          builder.insert_points.first.should == [1,0]
        end

      end

      context 'has line var0.collect {|x| x }' do

        let(:composite) do
          Cauldron::Solution::Composite.new( 
            [ ArrayCollect.new([0]) ]
          )
        end        

        it 'has 2' do
          builder.insert_points.length.should == 2
        end        

      end

    end

  end

end