require 'spec_helper'

module Cauldron
  
  describe 'Builder' do

    describe '#insert_points' do

      let(:builder) { Cauldron::Builder.new(composite) }

      context 'empty method' do

        let(:composite) do
          Cauldron::Solution::Composite.new([])
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
          Cauldron::Solution::Composite.new( 
            [Tree::TreeNode.new('CHILD', NumericOperator.new([0],4))]
          )
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
            [Tree::TreeNode.new('CHILD', ArrayCollect.new([0]) )]
          )
        end

        it 'has 2' do
          builder.insert_points.length.should == 2
        end

        it 'has one point at line 1 depth 0' do
          builder.insert_points.should include([1,0])
        end

        it 'has one point at line 1 depth 1' do
          builder.insert_points.should include([1,1])
        end

        context 'has line "var1 = 6" at line 1 depth 0' do

          let(:composite) do
            Cauldron::Solution::Composite.new(
              [
                Tree::TreeNode.new('CHILD1', ArrayCollect.new([0]) ),
                Tree::TreeNode.new('CHILD2', NumericOperator.new([0],6) )
              ]
            )
          end

          it 'has 2' do
            builder.insert_points.length.should == 2
          end

          it 'has one point at line 2 depth 0' do
            builder.insert_points.should include([2,0])
          end

          it 'has one point at line 1 depth 1' do
            builder.insert_points.should include([1,1])
          end

        end

        context 'has line "var2 = 7" at line 2 depth 0' do

          let(:composite) do
            Cauldron::Solution::Composite.new(
              [
                Tree::TreeNode.new('CHILD1', ArrayCollect.new([0]) ),
                Tree::TreeNode.new('CHILD2', NumericOperator.new([0],6) ),
                Tree::TreeNode.new('CHILD3', NumericOperator.new([0],7) )
              ]
            )
          end

          it 'has 2' do
            builder.insert_points.length.should == 2
          end

          it 'has one point at line 3 depth 0' do
            builder.insert_points.should include([3,0])
          end

          it 'has one point at line 1 depth 1' do
            builder.insert_points.should include([1,1])
          end                              

        end

      end

    end

    describe '#trace' do

      context 'composite is empty' do

        let(:builder) { Cauldron::Builder.new(composite) }

        let(:composite) { Cauldron::Solution::Composite.new([]) }

        context 'using param ["Sparky", "Kel"]' do

          let(:params) do
            ['Sparky', 'Kel']
          end

          it %q{is 
{:var0 => ['Sparky','Kel']}
            } do
              builder.trace(params).should == [ {:var0 => ['Sparky','Kel']} ]
          end

        end

      end

    end

  end

end