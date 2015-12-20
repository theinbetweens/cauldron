require 'spec_helper'

module Cauldron
  
  describe ArrayCollect do

    describe '#context_history' do

      context 'using ["lions", "bears"]' do

        let(:instance) { ArrayCollect.new([0]) }

        it "is [{x: 'lions'},{x: 'bears'}]" do
          instance.context_history(
            ['var0'],['lions','bears']
          ).should == [{x: 'lions'},{x: 'bears'}]
        end

      end

    end

    describe '#to_ruby' do

      let(:scope) { Cauldron::Scope.new(['var0']) }

      it 'returns "var0.collect { |x| x }"' do
        operator = ArrayCollect.new([0])
        operator.to_ruby([],scope).should == "var0.collect { |var1| }"
      end

      context 'passed "a * 2"' do

        it 'returns "var0.collect { |var1| var1 * 2}"' do
          a_times_2 = StringAsteriskOperator.new([1],2)
          operator = ArrayCollect.new([0])
          operator.to_ruby(
            [a_times_2], scope
          ).should == 'var0.collect { |var1| var1 * 2 }'
        end

      end

    end

    describe '.viable?' do

      context 'argument is an array' do

        it 'is true' do
          arg = []
          ArrayCollect.viable?( [arg], [] ).should be_true
        end

      end

    end

    describe '#successful?' do

      let(:first_argument) do
        ['a','b','c']
      end

      let(:bad_response) do
        ['a','b','d']
      end

      let(:operator) do
        ArrayCollect.new([0])
      end

      it 'is true' do
        problem = {arguments: [first_argument], response: ['a','b','c']}
        operator.successful?(problem).should == true
      end

      it 'is true' do
        problem = {arguments: [first_argument], response: bad_response}
        operator.successful?(problem).should be_false
      end      

    end

    describe '.step_problems' do

      context 'using arguments "["foo","lima"]" and "["bar","delta"]"' do

        it 'returns arguments "["foo","lima"]" and "["bar","delta"]"' do
          #ArrayCollect.step_problems(
          # Maybe blockify would be more appropriate
          ArrayCollect.step_problem(
            #[
              { arguments: [['foo','lima']], response: ['foofoo','limalima'] }#,
              #{ arguments: [['bar','delta']], response: ['barbar','deltadelta'] }
            #]            
          ).should == [
            { arguments: ['foo'], response: 'foofoo' },
            { arguments: ['lima'], response: 'limalima' }
          ]     
        end

      end

    end

    describe '#trace' do

      context 'promblem has argument "["foo","lima"]"' do

        it 'returns "["foo","lima"]"' do
          pending
          ArrayCollect.new([0]).trace(
            { arguments: [['foo','lima']] }
          ).should == ['foo','lima']
        end

      end

    end

  end

end