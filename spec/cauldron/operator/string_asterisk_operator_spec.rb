require 'spec_helper'

module Cauldron
  
  describe 'StringAsteriskOperator' do

    describe '.find_constants' do

      context 'argument string is "hello"' do

        context 'response string is hellohello' do

          it 'returns [2]' do
            problems = [
              { arguments: ['hello'], response: 'hellohello' }
            ]
            StringAsteriskOperator.find_constants(problems).should == [2]
          end

        end

        context 'response string is "foo"' do

          it 'returns []' do
            problems = [
              { arguments: ['hello'], response: 'foo' }
            ]
            StringAsteriskOperator.find_constants(problems).should == []  
          end

        end

      end

    end

    describe '.viable?' do

      context 'argument is a string' do

        context 'response is string' do

          it 'is true' do
            StringAsteriskOperator.viable?(['hello'],'hellohello').should be_true         
          end

        end

        context 'response is an array' do

          it 'is false' do
            StringAsteriskOperator.viable?(['hello'],['hellohello']).should be_false
          end

        end

      end

      context 'argument is not a string' do

        it 'is false' do
          StringAsteriskOperator.viable?([8],'hellohello').should be_false
        end

      end

    end    

    describe '.uses_constants?' do

      it 'is true' do
        StringAsteriskOperator.uses_constants?.should be_true
      end

    end

    describe '#successful?' do

      context 'argument string is "hello"' do

        context 'response string is hellohello' do

          context 'constant is 2' do

            it 'is true' do
              problem = { arguments: ['hello'], response: 'hellohello' }
              operator = StringAsteriskOperator.new(2)
              operator.successful?(problem).should be_true           
            end

          end

          context 'constant is 1' do

            it 'is false' do
              problem = { arguments: ['hello'], response: 'hellohello' }
              operator = StringAsteriskOperator.new(1)
              operator.successful?(problem).should be_false            
            end

          end

        end

      end      

    end

    describe '#to_ruby' do

      context 'constant is 2' do

        it 'returns "var0 * 2"' do
          operator = StringAsteriskOperator.new(2)
          operator.to_ruby.should == "  var0 * 2"+"\n"
        end

      end

    end

  end

end