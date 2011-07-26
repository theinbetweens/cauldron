module Cauldron::Util::Saver
  
  def self.save(obj)
    dir_path = FileUtils.mkdir(next_directory).first
   begin 
      dump_file_path = File.join(dir_path,'dump')
      dump_file = File.open(dump_file_path,'w+')
      data = Marshal.dump(obj)
      dump_file << data
      return dump_file_path
    ensure 
      dump_file.close
    end
  end
  
  def self.debug_directory
    # the home directory code is duplicated
    realHome = ["HOME", "HOMEPATH"].detect {|h| ENV[h] != nil}
    if not realHome
      StandardLogger.instance.warning "Couldn't detect a home directory"
    end
    return File.join(ENV[realHome],'cauldron','debug')    
  end   
  
  def self.next_directory
    FileUtils.mkdir(debug_directory) unless File.exists?(debug_directory)
    highest_integer = 0
    Dir.glob(File.join(debug_directory,'*')).each do |filename|
      if filename.match(/(\d+)/)
        highest_integer = $1.to_i if $1.to_i > highest_integer     
      end
    end
    return File.join(debug_directory,(highest_integer + 1).to_s)
  end
  
  def self.load(id)
    Dir.glob(File.join(debug_directory,'*')).each do |filename|
      if m = filename.match(/(\d+)/) and m[0].to_i == id
        dump_file = File.open(File.join(filename,'dump'),'r')
        return Marshal.load(dump_file.read)        
      end
    end
  end
  
end