# frozen_string_literal: true

module Cauldron
  class DynamicOperator
    include Cauldron::Operator

    attr_reader :indexes
    attr_accessor :failed_uses

    def initialize(information, sexp_methods)
      @information = information
      @sexp_methods = sexp_methods
      @failed_uses = []
      @closed = false
    end

    def uses_constants?
      @information[:constants]
    end

    def indexes=(value)
      raise StandardError, '' if @closed

      @indexes = value
    end

    def close
      @closed = true
    end

    def extend_actualized_composite(x, container, examples, point)
      cloned_container = container.clone_solution
      cloned_container.add_statement_at(x, point)
      cloned_container
      Cauldron::ActualizedComposite.new(cloned_container, examples)
    end

    def context_realizable?(context)
      vars = context.keys.select { |x| x.match(/var\d/) }
      var_names = vars.collect(&:to_s)

      a = %{
      def function(var0)
        #{Sorcerer.source(to_sexp(Cauldron::Scope.new(var_names), []), indent: true)}
      end
      }

      o = Object.new
      o.instance_eval(a)

      begin
        o.function(vars.collect { |x| context[x] })
      rescue NoMethodError => e
        return false
      rescue StandardError => e
        puts e
      end
      true
    end

    def write_to_file(filename)
      FileUtils.mkdir_p File.join('tmp')
      File.open(File.join('tmp', filename), 'w+') do |file|
        file << 'class DynamicOperator' + "\n"
        file << Sorcerer.source(@sexp_methods, indent: true)
        file << "\n"
        file << 'end'
      end
    end

    def rip2
      %{
      def function(var0)
        #{Sorcerer.source(to_sexp(Cauldron::Scope.new(['var0'])), indent: true)}
      end
      }
    end

    def rip(composite, examples)
      Ripper::SexpBuilder.new(
        %{
        def function(var0)
          #{composite.to_ruby(examples.scope)}
        end
      }
      ).parse
    end
  end
end
