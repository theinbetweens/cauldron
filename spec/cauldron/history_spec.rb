require 'spec_helper'

module Cauldron
  
  describe History do

    describe '#insert_points' do

      context %q{given the history is 
        History is:
          [line: 0, depth:0, var0: ['Sparky','Kel'] ]
      } do

        let(:subject) { History.new([{line: 0, depth: 0, point: [0], var0: ['Sparky','Kel'] }]) }

        it 'has 1 insert point' do
          subject.insert_points.should have(1).insert_point
        end

        it 'has the insert point [0,0]' do
          subject.insert_points.should include([0])
        end

      end

      context %q{given the history is 
        History is:
          [line: 1, depth:0, var0: 'Sparky', var1: 'Spark' ]
        from:
          var1 = var0.chop
        } do

        let(:subject) { History.new([{line: 1, depth: 0, point: [1], var0: 'Sparky', var1: 'Spark'}]) }

        it 'has 1 insert point' do
          subject.insert_points.should have(1).insert_point
        end 
          
        it 'has the insert point [1,0]' do
          subject.insert_points.should include([1])
        end                   

      end

      context %q{
        History is:
          [line: 1, depth:1, total_line: 2, point: [0,1], var0: ['Sparky', 'Kels'], var1: 'Spark' ],
          [line: 1, depth:1, total_line: 2, point: [0,1], var0: ['Sparky', 'Kels'], var1: 'Kel' ],
          [line: 1, depth:0, total_line: 2, point: [1], var0: ['Sparky', 'Kels'], var1: 'Kel', var2: ['Spark', 'Kel'] ],
        from:
          var2 = var0.each do |var1|
            var1.chop
          end
        } do

          let(:subject) { 
            History.new([
              {line: 1, depth:1, total_line: 2, point: [0,1], var0: ['Sparky', 'Kels'], var1: 'Spark'},
              {line: 1, depth:1, total_line: 2, point: [0,1], var0: ['Sparky', 'Kels'], var1: 'Kel'},
              {line: 1, depth:0, total_line: 2, point: [1], var0: ['Sparky', 'Kels'], var1: 'Kel', var2: ['Spark', 'Kel']}
            ]) 
          }

          it 'has 2 insert point' do
            subject.insert_points.should have(2).insert_point
          end

          it 'has the insert point [1]' do
            subject.insert_points.should include([1])
          end

          it 'has the insert point [0,1]' do
            subject.insert_points.should include([0,1])
          end                               

      end

    end

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