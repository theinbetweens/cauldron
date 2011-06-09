module WriteParameters
  
  def write_params(params,parenthesis=['(',')'])
    line = ''
    unless params.empty? 
      line += parenthesis[0]
      params.each_with_index do |var,i|
        line += var.write
        unless var.object_id ==params.last.object_id
          line += ', '
        end
      end
      line += parenthesis[1]
      return line
    end    
    return ''
  end
  
  def describe_params(params,parenthesis=['(',')'])
    line = ''
    unless params.empty? 
      line += parenthesis[0]
      params.each_with_index do |var,i|
        line += var.describe
        unless var.object_id ==params.last.object_id
          line += ', '
        end
      end
      line += parenthesis[1]
      return line
    end    
    return ''
  end  
  
end