require 'spec_helper'

module Cauldron
  
  describe 'ChainCollection' do 
    
    describe '#next_chain' do
      context 'demo 1 and 2 theories have been saved' do
        it 'should return a chain instance' do
          cases = []
          cases << convert_to_example(separate_values("'sparky','bro'"))
          cases << convert_to_example(separate_values("'kel','sis'"))
          collection = ChainCollection.new(cases)         
          collection.next_chain.should be_an_instance_of UnifiedChain
        end
        it 'should return the same chain instance sequence' do
          cases = []
          cases << convert_to_example(separate_values("'sparky','bro'"))
          cases << convert_to_example(separate_values("'kel','sis'"))
          first_collection = ChainCollection.new(cases)
          second_collection = ChainCollection.new(cases)
          first_collection.next_chain.theories_sequence.should == second_collection.next_chain.theories_sequence           
        end
        it 'should exclude requested chains' do
          cases = []
          cases << convert_to_example(separate_values("'sparky','bro'"))
          cases << convert_to_example(separate_values("'kel','sis'"))
          first_collection = ChainCollection.new(cases)
          first_sequence = first_collection.next_chain.theories_sequence
          second_collection = ChainCollection.new(cases)
          second_collection.exclude(first_sequence)
          second_collection.next_chain.theories_sequence.should_not == first_sequence                    
        end
      end
    end
    
  end

end