module Cauldron
  
  class TheoryParser
    
    def parse(yaml)
      dependents = yaml['dependents'].collect do |dependent_string|
        parser = RubyParser.new
        sexp = parser.process(dependent_string)                
        sexp2cauldron = Sexp2Cauldron.new    
        sexp2cauldron.process(sexp)        
      end
      results = yaml['results'].collect do |result_string|
        parser = RubyParser.new
        sexp = parser.process(result_string)                
        sexp2cauldron = Sexp2Cauldron.new    
        sexp2cauldron.process(sexp)        
      end
      Theory.new(dependents,nil,results)
    end
    
    def parse_action(data)
      
      parser = RubyParser.new
      sexp2cauldron = Sexp2Cauldron.new
            
      # Create the full action statement
      # TODO Look up %{} notiation substitutions
      parsed_statement = data['statement']
      data['values'].each_pair do |key,value|
        parsed_statement.gsub!(key,value)
      end
      if parsed_statement.match(/^if/)
        parsed_statement += "\nend"
      end
      
      # Update the position where the action is inserted
      parsed_position = data['position']
      data['values'].each_pair do |key,value|
        parsed_position.gsub!(key,value)
      end      
      sexp_2 = parser.process(parsed_position)                
      statement_2 = sexp2cauldron.process(sexp_2)      
      
      sexp = parser.process(parsed_statement)                    
      statement = sexp2cauldron.process(sexp)
      
      action = nil
      if statement.kind_of?(OpenStatement)
        nodes = []
        statement.statement.each do |node|
          nodes << node  
        end
        theory_statement = TheoryStatement.new(
          OpenStatement.new(
            TheoryStatement.new(*nodes)
          )
        )
        action = theory_statement
        #puts '=================================='
        #debugger
        target_id = statement_2
        # puts TheoryAction.new(
          # action,
          # target_id
        # ).write        
        return TheoryAction.new(
          action,
          target_id
        )
        
        
      elsif statement.kind_of?(Statement)
        raise StandardError.new('Not implemented yet')
      end
      
      #OpenStatement.new()
      #theory_statement = TheoryStatement.new(*nodes)
      
      #puts theory_statement.write      
      #puts '--------------------------'
      #TheoryResult.new()
    end
    
  end
  
end