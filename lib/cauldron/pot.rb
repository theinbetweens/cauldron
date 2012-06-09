module Cauldron

  class Pot
    
    def generate(cases)
      if theories.empty?
        return "There aren't any theories loaded so Cauldron is unable to generate a solution"
      end

      # Generate a resulting function using the available theories
      empty_function = Function.new
      # TODO I need a proper $STDOUT check so I don't need this puts
      puts 'WARREN------------============='
      puts theories.length
      puts theories.first.insert_statement('AHSDS')
      puts 'WARREN-END------------============='
      output = empty_function.apply_theory(theories.first,cases.first).write
      puts output
      output
      #empty_function.apply_theory(theories.first).write
    end
    
    def load_theory(filepath)
      theory = TheoryParser.new.parse(filepath)
      theories << theory
      return true
    end

  protected    
    
    def theories
      @theories ||= []
    end
    
  end
  
end