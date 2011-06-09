class StandardLogger
  include Singleton
  
  def initialize
    @log = Logger.new(STDOUT)
    @log.level = Logger::INFO
    @log.datetime_format = "%H:%M:%S"
    
    # TODO  Include option to print to file as well see Logger class to
    #       allow this.
    # or
    # http://www.ruby-doc.org/stdlib/libdoc/logger/rdoc/index.html
  end
  
  def info(msg)
    @log.info(msg)
  end
  
  def code(msg)
    @log.info("\n"+msg)
  end
  
  def error(msg)
    @log.error("\033[0;31m\ "+msg+"\033[00m\ ")
  end
  
  def warning(msg)
    error(msg)
  end
  
  def deprecated(msg)
    error(msg)
  end
  
  # TODO  Do this properly with method missing etc
  def method_missing(sym, *args, &block)
    @log.send sym, *args, &block
  end  
  
  # Prints out the code that lead to the current error being raised.
  #
  # @param  trace   An array of lines each of which should be printed out
  #
  def backtrace(trace)
    trace.each do |t|
      @log.error("\033[0;33m\ "+t+"\033[00m\ ")
    end
  end
  
#
#red = "\0123" # character code
#white = "\0223"
#
#
## http://ubuntuforums.org/showthread.php?t=470626
## http://kpumuk.info/ruby-on-rails/colorizing-console-ruby-script-output/
## http://en.wikipedia.org/wiki/ANSI_escape_code#Codes
##
#print "#{red} ERROR: IT BROKE #{white}"
#print "other stuff"
  
end