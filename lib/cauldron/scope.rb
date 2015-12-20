module Cauldron

  class Scope
    include Enumerable

    attr_reader :variables

    def initialize(variables)
      @variables = variables
    end

    def new_variable!
      #@variables << "var#{variables.length+1}"
      @variables << "var#{variables.length}"
      @variables.last
    end

    def [](index)
      variables[index]
    end

  end

end