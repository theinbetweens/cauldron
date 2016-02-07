module Cauldron

  class History

    attr_reader :logs

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

    def insert_points
      logs.collect {|x| x[:point] }.uniq
    end

  end

end