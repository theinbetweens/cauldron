class HashAccess
  
  attr_reader :hash, :key
  
  def initialize(array,index)
    @hash = array    
    @key = index
  end

  def write
    return @hash.write+'['+@key.write+']'
  end  
  
  def copy
    return HashAccess.new(@hash.copy,@key.copy)
  end  
  
end