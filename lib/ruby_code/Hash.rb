class Hash
  
  def write
    #raise StandardError.new('No "write" method has been created for '+self.class.to_s) unless self.class.to_s == 'Hash'
    line = '{' 
    count = 0
    self.each do |x,y|
      line += x.write+'=>'+y.write
      count += 1 
      next if count == self.length
      line += ','
    end
    line += '}'
    return line    
  end
  
  def copy
    raise StandardError.new('No "copy" method has been created for '+self.class.to_s) unless self.class.to_s == 'Hash'    
    return self.inject({}) do |x,(key,value)|
      x[key] = value
      x
    end
  end
  
end