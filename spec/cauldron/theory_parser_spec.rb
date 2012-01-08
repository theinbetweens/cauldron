require 'spec_helper'

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
        
        it 'should return a chain with correct 2 dependents' do
          # TODO Ideally I would instaniate the chain and use == to check the loaded chain is correct
          
          # TODO ------------ None of the dependetnts checking ! Just create the full chain and check
          # =>        I know it is long but it's the proper test
          parser = TheoryParser.new
          parser.parse(
            YAML.load(File.open(File.join('spec','examples','adding_if_statement.yml')))
          ).dependents.should have(2).dependents
        end        

      end      
      
    end
    
  end
  
end