module Cauldron

  class Histories

    def initialize(results)
      @results = results
    end

    def variable_permutations(count)
      [@results.first.logs.first]
    end

    def each(&block)
      @results.each(&block)
    end 

    def first
      @results.first
    end

  end

end