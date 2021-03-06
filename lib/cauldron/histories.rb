# frozen_string_literal: true

module Cauldron
  class Histories
    def initialize(results)
      @results = results
    end

    def variable_permutations(_count)
      variables = @results.first.logs.first.keys.select { |x| x.match /var/ }
      v = Hash[*variables.collect { |x| [x, nil] }.flatten]

      @results.collect do |history|
        history.logs.collect do |a|
          Hash[*v.keys.collect do |x|
            [x, a[x]]
          end.flatten(1)]
        end
      end.flatten
    end

    def each(&block)
      @results.each(&block)
    end

    def first
      @results.first
    end

    def length
      @results.length
    end

    def insert_points
      @results.inject([]) { |total, x| total += x.insert_points; total }.uniq
    end

    def contexts_at(point)
      a = []
      @results.each do |history|
        a += history.logs.each_with_object([]) do |log, total|
          total << log if log[:point] == point
        end
      end
      a
    end
  end
end
