module Cauldron
  
  class TheoryParser
    
    def parse(yaml)
      dependents = yaml['dependents'].collect do |dependent_string|
        parser = RubyParser.new
        puts dependent_string
        sexp = parser.process(dependent_string)                
        sexp2cauldron = Sexp2Cauldron.new    
        sexp2cauldron.process(sexp)        
      end
    end
    
  end
  
end