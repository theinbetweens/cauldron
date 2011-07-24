module Cauldron
  
  module Util
  
  module Home
    
    private 
    
      # Check that the home directory exists
      def home
        realHome = ["HOME", "HOMEPATH"].detect {|h| ENV[h] != nil}
        if not realHome
          StandardLogger.instance.warning "Couldn't detect a home directory"
        end
        return ENV[realHome]  
      end      
    
  end
  
  end
end