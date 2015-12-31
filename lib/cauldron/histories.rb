module Cauldron

  class Histories

    def initialize(results)
      @results = results
    end

    def variable_permutations(count)
      variables = @results.first.logs.first.keys.select { |x| x.match /var/ }
      v = Hash[*variables.collect {|x| [x,nil]}.flatten]
      #[@results.first.logs.first]
      # @results.first.logs.collect do |a|
      #   Hash[*v.keys.collect do |x| 
      #     [x, a[x] ] 
      #   end.flatten]
      # end

      @results.collect do |history|
        history.logs.collect do |a|
          Hash[*v.keys.collect do |x| 
            [x, a[x] ] 
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

  end

end