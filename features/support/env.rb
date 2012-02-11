$LOAD_PATH << File.expand_path('../../../lib',__FILE__)

require 'ruby-debug'
require 'cauldron'

require 'aruba/cucumber'
# See https://github.com/cucumber/aruba/blob/master/lib/aruba/cucumber.rb for the available steps

class Output
  
  def messages
    @messages ||= []
  end
  
  def puts(message)
    messages << message
  end
  
end

def output
  @output ||= Output.new
end

def home
  realHome = ["HOME", "HOMEPATH"].detect {|h| ENV[h] != nil}
  if not realHome
    raise "Couldn't detect a home directory"
  end
  return ENV[realHome]  
end 