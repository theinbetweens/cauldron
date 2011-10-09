# TODO  This instance should replace the write method in ActsAsRuntimeMethod

class MethodWriter
  include WriteParameters
  
  def initialize
    
  end
  
  def write(params,statements,tab=0,method_id=0,additional_comments='')

    line = "\n"    
    tab.times {|x| line += "  " }
    line += "#\n"

    params.each_with_index do |var,i|       
      tab.times {|x| line += "  " }
      line += "#  @param  "
    
      # Get a description of the requirements (this can multiple lines)
      line_prefix = ''
    
      desc = var.describe(tab)
      desc.each_line do |l|
        line += line_prefix+l
        
        # Assides the first line pre-fix a "#      " to the start
        (tab-1).times {|x| line += "  " }
        line_prefix = "#      "
        
      end
      
    end
    
    # Add some some additional comment if supplied
    unless additional_comments.nil?
      tab.times {|x| line += "  " }
      line += "#"
      tab.times {|x| line += "  " }
      line += additional_comments+"\n"
    end    
    
    tab.times {|x| line += "  " }
    line += "#\n"               
    
    tab.times {|x| line += "  "}
    line += 'def method_'+method_id.to_s 
    
    #line += write_params(@parameters)
    line += write_params(params)
    line += "\n"
    
    # Write out any statements within the method
    statements.each do |statement|
      line += statement.write(tab+1)+"\n"
    end
    line += "\n" if statements.empty?
    
    # Close the method
    tab.times {|x| line += "  " }
    line += "end"+"\n"
    
    return line    
  end
  
end