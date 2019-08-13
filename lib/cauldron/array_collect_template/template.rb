# frozen_string_literal: true

module Cauldron
  module ArrayCollectTemplate
    class Template < Cauldron::TemplateBase
      def self.instances(histories, composite, examples, insert_points)
        # TEMP
        unless examples.class == ExampleSet
          raise StandardError, 'Examples should be an example'
        end

        # Print out each insertable statements
        scope = examples.scope

        # self.init([0]).to_ruby(scope)
        # - this will print out "var0.chop"

        # Get the variables available at each point
        results = []

        insert_points.each do |point|
          # Find the variables at a particular point
          # TODO Change to test
          contexts = histories.contexts_at(point)
          composites = context_instances(contexts)

          composites.each do |x|
            if contexts.all? { |context| x.context_realizable?(context) }
              # binding.pry
              results << extend_actualized_composite(x, composite, examples, point)
            end
            # results << extend_actualized_composite(x, composite, examples, point)
          end
        end

        results
      end

      def self.context_instances(contexts)
        temp = []
        contexts.each do |context|
          temp << context.keys.collect(&:to_s).select { |x| x.match(/var\d/) }
        end
        results = temp.flatten.uniq

        variable_numbers = results.collect { |x| x.match(/var(\d+)/)[1] }
        variable_numbers.collect { |x| Cauldron::ArrayCollectTemplate::Default.new([x.to_i]) }
      end
    end
  end
end
