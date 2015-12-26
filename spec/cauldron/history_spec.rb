require 'spec_helper'

module Cauldron
  
  describe History do

    describe '#variables' do

      context %q{
        History is:
          [line: 0, depth:0, var0: ['Sparky','Kel'] ]
      } do

        let(:history) { History.new([{line: 0, depth: 0, var0: ['Sparky','Kel'] }]) }

        it 'returns "var0"' do
          history.variables.should == [:var0]
        end

      end

    end

    describe '#values' do

      context %q{
        History is:
          [line: 0, depth:0, var0: ['Sparky','Kel'] ]
      } do

        let(:history) { History.new([{line: 0, depth: 0, var0: ['Sparky','Kel'] }]) }

        it %q{returns "[ ['Sparky','Kel'] ]"} do
          history.values(:var0).should == [
            ['Sparky','Kel']
          ]
        end

      end

    end

  end

end