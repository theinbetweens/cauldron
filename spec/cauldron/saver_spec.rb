require 'spec_helper'

module Cauldron
  
  module Util
  
    describe Saver do 
      
      describe '.save' do
        it 'can save a string object without raising an exception' do
          lambda {Cauldron::Util::Saver.save('geth')}.should_not raise_error        
        end
        it 'will return the path to saved string object after saving it' do
          Cauldron::Util::Saver.save('Normandy').should match(/cauldron\/debug/)
        end
      end
      
      describe '.debug_directory' do
        it 'should return the path to the debug directory' do
          Cauldron::Util::Saver.debug_directory.should include("/cauldron/debug")
        end
      end
      
      describe '.next_directory' do
        it "should return the path to a directory that doesn't exist" do
          Cauldron::Util::Saver.next_directory.should match(/cauldron\/debug\/\d+/)
        end
        it 'should not return the path to an existing directory' do
          File.exists?(Cauldron::Util::Saver.next_directory).should_not == true
        end
      end
      
      describe '.load' do 
        it 'can load a saved obj' do
          path = Cauldron::Util::Saver.save('Adele & Kirk')
          path_id = path.match(/(\d+)/)[0].to_i
          Cauldron::Util::Saver.load(path_id).should == 'Adele & Kirk' 
        end
      end
      
    end
  
  end

end