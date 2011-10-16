require 'spec_helper'

StandardLogger.instance.level = Logger::FATAL

module Cauldron
  
  describe TheoryConnector do
    
    describe '#generate_chains' do
      context 'when it has demo 1 theories' do
        it 'will generate just one chain' do
          theories = demo_one[:chain].collect {|x| x}
          runtime_method = demo_one[:initial_method]
          test_cases = demo_one[:test_cases]
          
          connector = TheoryConnector.new(demo_one[:values])
          connector.generate_chains(runtime_method,test_cases,theories).length.should == 1
        end
      end
      context "when it has demo two's theories" do
        it 'will generate just one chain' do
          theories = demo_two[:chain].collect {|x| x}
          runtime_method = demo_two[:initial_method]
          test_cases = demo_two[:test_cases]
          
          connector = TheoryConnector.new(demo_two[:values])
          connector.generate_chains(runtime_method,test_cases,theories).length.should == 1          
        end
      end
      context "when it has both demo one and two's theories" do
        it 'will generate just one chain' do
          @theories = demo_one[:chain].collect {|x| x} + demo_two[:chain].collect {|x| x}
          runtime_method = demo_one[:initial_method]
          test_cases = demo_one[:test_cases]
          
          connector = TheoryConnector.new(demo_one[:values])
          connector.generate_chains(runtime_method,test_cases,@theories).length.should == 2          
        end
        it 'will generate two chains when given demo two test cases' do
          @theories = demo_one[:chain].collect {|x| x} + demo_two[:chain].collect {|x| x}
          runtime_method = demo_two[:initial_method]
          test_cases = demo_two[:test_cases]
          
          connector = TheoryConnector.new(demo_one[:values])
          connector.generate_chains(runtime_method,test_cases,@theories).length.should == 2          
        end
      end
    end
    
  end
  
end