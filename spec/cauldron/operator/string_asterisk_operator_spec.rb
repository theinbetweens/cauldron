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

  end

end