module Cauldron

  class History

    def initialize(logs)
      @logs = logs
    end

    def variables
      results = []
      @logs.select do |line|
        results += line.keys.select {|x| x.match(/var*/) }
      end
      results
    end

    def values(variable_name)
      @logs.inject([]) do |total,line|
        if line.has_key?(variable_name)
          total << line[variable_name]
        end
        total
      end
    end

  end

end