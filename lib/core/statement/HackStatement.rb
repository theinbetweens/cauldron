# This is a temporary statement that simple writes out the string provided to it.  It
# is used by the RuntimeTrackingMethod and is simple used now because I am not
# able to create hashes just yet.  I hope to remove this class in the foreseable
# future(15/07/09) - lets see.
#
class HackStatement < Statement
  
  def initialize(statement_text)
    super()
    @statement_text = statement_text  
    @confirmed = true    
    @statement_type = 'Hack'
  end
  
  def write(tab=0)
    l = ''
    tab.times {|x| l += "\t" }
    return l+@statement_text
  end
  
  def copy
    return HackStatement.new(@statement_text.dup)         
  end
  
end