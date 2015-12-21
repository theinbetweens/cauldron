module Cauldron

  class Builder

    attr_reader :composite

    def initialize(composite)
      @composite = composite
    end

    def insert_points
      results = [
        [composite.operators.length,0]
      ]
      if composite.operators.collect(&:first).count {|x| x.branch? }
        branches = composite.operators.collect(&:first).select {|x| x.branch? }
        branches.each do |x|
          results << [branches.length, 1]
        end
      end
      results
    end

  end

end