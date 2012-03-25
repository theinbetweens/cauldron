require 'spec_helper'

module Cauldron
  
  describe 'TheoryParser' do 
   
    describe '#parse' do
      
      let(:data) {%q{
dependents:
  :1
    if RUNTIME_METHOD.kind_of?(RuntimeMethod)
      return true
    end
  :2
    if ARG_1 == OUTPUT
      return true
    end
action:
  statement: "return x"
  values
    x: ARG_1
  position: RUNTIME_METHOD.first.statement_id
results:
  :1
    RUNTIME_METHOD.all_pass(ARG_1)
} 
    }
      
      it 'should generate a theory instance from a valid theory file' do 
        parser = TheoryParser.new
        f = double(:file) 
        f.stub(:read) { StringIO.new(data.strip) }
        File.stub(:open).with('example.yml').and_return(f)      
        parser.parse('example.yml').should be_an_instance_of(Theory)
      end
      
      it 'should generate an accurate runtime method' do
        parser = TheoryParser.new
        f = double(:file)
        #f.stub(:read) { StringIO.new(data.strip) }
#t = %q{
#  dependents:'adfdas'
#}
        f.stub(:read) { StringIO.new(t.strip) }
        f.stub(:load) { StringIO.new(t.strip) }
        #f.stub(:load).and_return(StringIO.new(t.strip))
        f.should_receive(:load)
        #File.stub(:open).with('example.yml').and_return(f)      
        File.stub(:open).with('example.yml').and_yield(f)
        #YAML.stub(:load).with('example.yml').and_return(f)
        parser.parse('example.yml').should == Theory.new(
          [
            "if RUNTIME_METHOD.kind_of?(RuntimeMethod)
              return true
            end",
            "if ARG_1 == OUTPUT
              return true
            end"                        
          ],
          {:statement => 'return x',:values => {:x => 'ARG_1'},:position => 'RUNTIME_METHOD.first.statement_id'},
          ['RUNTIME_METHOD.all_pass(ARG_1)']
        )       
      end
      
    end
    
  end
  
end
