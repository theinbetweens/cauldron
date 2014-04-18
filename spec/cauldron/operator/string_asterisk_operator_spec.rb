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

  end

end