require 'spec_helper'

module Cauldron
  
  describe 'TheoryParser' do 
   
    describe '#parse' do
      
      let(:data) {%q{
dependents:
  -
    "if RUNTIME_METHOD.kind_of?(RuntimeMethod)
      return true
    end"
  -
    "if ARG_1 == OUTPUT
      return true
    end"
action:
  statement: "return x"
  values:
    x: ARG_1
  position: RUNTIME_METHOD.first.statement_id
results:
  -
    RUNTIME_METHOD.all_pass(ARG_1)
    }
    }
      it 'should generate a theory instance from a valid theory file' do 
        File.stub(:open).with('example.yml').and_yield(StringIO.new(data.strip))              
        TheoryParser.new.parse('example.yml').should be_an_instance_of(Theory)
      end
      
      it 'should generate an accurate runtime method' do
        parser = TheoryParser.new
        File.stub(:open).with('example.yml').and_yield(StringIO.new(data.strip))

        TheoryParser.new.parse('example.yml').should == Theory.new(
          [
%q{
if RUNTIME_METHOD.kind_of?(RuntimeMethod) return true end
}.strip,
%q{
if ARG_1 == OUTPUT return true end
}.strip                        
          ],
          {'statement' => 'return x','values' => {'x' => 'ARG_1'},'position' => 'RUNTIME_METHOD.first.statement_id'},
          ['RUNTIME_METHOD.all_pass(ARG_1)']
        )       
      end
      
    end
    
  end
  
end
