module Cauldron

  class Pot
    
    def generate(*params)
      if theories.empty?
        return "There aren't any theories loaded so Cauldron is unable to generate a solution"
      end
      printed_method = 
%q{
def method_0(var_0)
  return var_0
end                  
}
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