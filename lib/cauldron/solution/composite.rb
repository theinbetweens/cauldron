module Cauldron::Solution

  class Composite

    attr_reader :operators

    def initialize(*operators)
      @operators = operators
    end

    def sexp
      operators.shift.build(operators)
    end
    
  end

end