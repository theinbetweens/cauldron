class StatementCheck
  
  # This writes and evalutes the syntax of a statement to
  # determine whether it can be used by it self.  
  # 
  # So something like var1 = var0.chop would fail since
  # var0 doesn't exist.  It needs to write to a different
  # class to avoid the situation where the statement
  # 'return false' would perceived as invalid syntax.
  # 
  def valid_syntax?(statement)
    
    # Create file to include the test method
    filepath = $LOC+File.join(['tmp','runtime_statement_check.rb'])    
    file = File.open(filepath,'w+')
    
    # Include the sytax for the statement in the file
    file << 'class RuntimeStatementCheck'+"\n"
    file << "\t"+'def check'+"\n"
    file << "\t\t"+statement+"\n"
    file << "\t"+'end'+"\n"
    file << 'end'
    file.close
    
    # Load the newly created class and check the statement
    begin    
      load filepath
      RuntimeStatementCheck.new.check
    rescue NameError => e
      return false
    rescue StandardError => e
      StandardLogger.log e
      return false
    rescue SyntaxError => e
      StandardLogger.log e
      return false      
    end
    return true    
    
  end

end