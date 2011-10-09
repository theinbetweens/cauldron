require 'spec_helper'

module Cauldron
  
  describe "Terminal" do
    
    let(:output) {double('output').as_null_object}
    let(:terminal) {Terminal.new(output)}
    
    describe '#start' do
      it 'sends an introduction message' do 
        output.should_receive(:puts).with("Thanks for trying Cauldron - it's at really early stage right now")
        terminal.start        
      end
      it 'sends instruction message' do 
        output.should_receive(:puts).with("To start enter your first test like this")
        output.should_receive(:puts).with("input,input,output")
        output.should_receive(:puts).with("For example ")
        output.should_receive(:puts).with("and when you're done just type RUN")
        terminal.start
      end
    end
    
    describe '#submit' do
      context "with example case \"'sparky', 'sparky'\"" do
        subject do
          terminal.submit "'sparky','sparky'"
          terminal.submit "'kel','kel'"
          terminal.cases
        end
        its([0]) { should eq({:output=>"sparky", :params=>["sparky"]}) }
        its([1]) { should eq({:output=>"kel", :params=>["kel"]}) }
      end   
      context 'with example case "sparky", "sparky"' do
        subject do
          terminal.submit '"sparky","sparky"'
          terminal.submit '"kel","kel"'
          terminal.cases
        end
        its([0]) { should eq({:output=>"sparky", :params=>["sparky"]}) }
        its([1]) { should eq({:output=>"kel", :params=>["kel"]}) }
      end
      it 'should clear the existing test cases after RUN command' do
        terminal.cases.should_receive(:clear)
        terminal.cases.length.should == 0
        terminal.start 
        terminal.submit '"sparky","sparky"'
        terminal.submit '"kel","kel"'
        terminal.submit 'RUN'
      end            
    end
      
  end
  
end