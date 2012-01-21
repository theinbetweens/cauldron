require 'spec_helper'

RSpec::Matchers.define :match_the_format do |format|
  match do |actual|
    actual.action.write == format
  end
  
  failure_message_for_should do |actual|
    "expected '#{actual.action.write}' to match the format '#{expected}'"
  end
    
end

module Cauldron
  
  describe 'TheoryParser' do
    
    describe '#parse' do
      
      context "when interpreting the YAML chain 'adding_if_statement.yml'" do
        
        it 'should return a theory when passed a YAML theory file' do
          parser = TheoryParser.new
          parser.parse(
            YAML.load(File.open(File.join('spec','examples','adding_if_statement.yml')))
          ).should be_an_instance_of(Theory)
        end
        
        it 'should return a theory with 2 dependents' do
          # TODO Ideally I would instaniate the chain and use == to check the loaded chain is correct
          
          # TODO ------------ None of the dependetnts checking ! Just create the full chain and check
          # =>        I know it is long but it's the proper test
          parser = TheoryParser.new
          parser.parse(
            YAML.load(File.open(File.join('spec','examples','adding_if_statement.yml')))
          ).dependents.should have(2).dependents
        end        
        
        it 'should create the "results" from the file' do
          parser = TheoryParser.new
          parser.parse(
            YAML.load(File.open(File.join('spec','examples','adding_if_statement.yml')))
          ).results.should have(3).results          
        end

      end      
      
    end
    
    describe '#parse_action' do
      
      context 'when parsing the action in "adding_if_statement.yml"' do
        
        it 'should return a theory action' do
          action_data = {
            "position"=>"var1.statement_id",
            "values"=>{
                        "x"=>"var1.params[var3]", 
                        "y"=>"var2[var4][:params][var5]"
                      },
            "statement"=>"if x == y"
          }
          parser = TheoryParser.new
          # TODO Should have a matcher for same structure
          parser.parse_action(action_data).should match_the_format "if varA.params[varC] == varB[varD][:params][varE]"
        end        
        
      end
      
    end
    
  end
  
end