class DeclarationStatementEvaluation
  
  # NOTE  It might improve performance if this was a singleton
  def evaluate(written_statement,runtime_methods=[])
    
    # Create file to include the test method
    file = Tempfile.new("runtime_declaration_statement_evaluation.rb")   
    
    # Include the sytax for the statement in the file
    file << 'class RuntimeDeclarationStatementEvaluation'+"\n"
    file << "\t"+'def check'+"\n"
    file << written_statement
    file << "\t"+'end'+"\n"
    
    # Add and associated runtime methods
    runtime_methods.each do |x|
      file << x.write
    end    
    
    file << 'end'
    file.close
    
    # Load the newly created class and check the statement
    load filepath
    return RuntimeDeclarationStatementEvaluation.new.check      
        
  ensure 
      file.close
      file.unlink          
  end
  
end