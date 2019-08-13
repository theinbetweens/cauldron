# frozen_string_literal: true

module Cauldron
  class History
    attr_reader :logs

    def initialize(logs)
      @logs = logs
    end

    def variables
      results = []
      @logs.select do |line|
        results += line.keys.select { |x| x.match(/var*/) }
      end
      results
    end

    def values(variable_name)
      @logs.each_with_object([]) do |line, total|
        total << line[variable_name] if line.key?(variable_name)
      end
    end

    def insert_points
      logs.collect { |x| x[:point] }.uniq
    end
  end
end
