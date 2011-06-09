class UnliteralisableError < StandardError
  
  def initialize(msg)
    super(msg)  
  end
  
end