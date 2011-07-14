module Cauldron::Util::Saver
  
  def self.save(obj)
    data = Marshal.dump(obj)
    dump_file = File.open(File.join(directory_path,'dump'),'r')
    dump_file << data 
    dump_file.close
  end
  
  private 
  
    # Check that the home directory exists
    # => TODO Duplicated in pot.rb  
    def home
      realHome = ["HOME", "HOMEPATH"].detect {|h| ENV[h] != nil}
      if not realHome
        StandardLogger.instance.warning "Couldn't detect a home directory"
      end
      return ENV[realHome]  
    end  
  
end