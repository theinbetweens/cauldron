module Cauldron

  class Scope
    include Enumerable

    attr_reader :variables

    def initialize(variables)
      @variables = variables
    end

    def new_variable!
      @variables << "var#{variables.length+1}"
      @variables.last
    end

  end

end