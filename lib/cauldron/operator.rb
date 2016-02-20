module Cauldron

  module Operator

    def context_instances(contexts)
      results = []
      contexts.each do |context|
        results << context.keys.collect(&:to_s).select {|x| x.match(/var\d/) }
      end
      results = results.flatten.uniq
      variable_numbers = results.collect { |x| x.match(/var(\d+)/)[1] }
      variable_numbers.collect { |x| init([x.to_i])}
    end    
    
  end

end