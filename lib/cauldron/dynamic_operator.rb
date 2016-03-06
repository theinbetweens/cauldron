module Cauldron

  class DynamicOperator

    include Cauldron::Operator

    attr_reader :indexes
    attr_accessor :failed_uses

    def initialize(information, sexp_methods)
      @information, @sexp_methods = information, sexp_methods
      @failed_uses = []
      @closed = false
    end

    def uses_constants?
      @information[:constants]
    end

    def indexes=(value)
      raise StandardError.new('') if @closed
      @indexes = value
    end

    def close
      @closed = true
    end

    # def clone_statement
    #   # TODO Need to clone the sexp methods
    #   # o = DynamicOperator.new(@information, @sexp_methods)
    #   # o.instance_eval(Sorcerer.source(@sexp_methods, indent: true))
    #   # o
    #   self.init(@indexes.clone)
    # end

    # def context_instances(contexts)
    #   results = []
    #   contexts.each do |context|
    #     results << context.keys.collect(&:to_s).select {|x| x.match(/var\d/) }
    #   end
    #   results = results.flatten.uniq
    #   variable_numbers = results.collect { |x| x.match(/var(\d+)/)[1] }
    #   variable_numbers.collect { |x| init([x.to_i])}
    # end

    def extend_actualized_composite(x, container, examples, point)
      cloned_container = container.clone_solution
      cloned_container.add_statement_at(x, point)
      cloned_container
      Cauldron::ActualizedComposite.new(cloned_container, examples)
    end

    def context_realizable?(context)
      
      vars = context.keys.select {|x| x.match(/var\d/) }
      var_names = vars.collect(&:to_s)
      # binding.pry
      # a = %Q{
      # def function(var0)
      #   #{Sorcerer.source(to_sexp(var_names), indent: true)}
      # end
      # } 
      a = %Q{
      def function(var0)
        #{Sorcerer.source(to_sexp(Cauldron::Scope.new(var_names), []), indent: true)}
      end
      }       

      o = Object.new
      o.instance_eval(a)

      begin
        o.function(vars.collect {|x| context[x] })  
      rescue NoMethodError => e
        return false
      rescue StandardError => e
        puts e
      end
      return true
      
    end

    def write_to_file(filename)
      File.open( File.join('tmp',filename), 'w+') do |file|
        file << "class DynamicOperator"+"\n"
        file << Sorcerer.source(@sexp_methods, indent: true)
        file << "\n"
        file << "end"
      end
    end

    def rip2
      %Q{
      def function(var0)
        #{Sorcerer.source(to_sexp(Cauldron::Scope.new(['var0'])), indent: true)}
      end
      }
    end

    def rip(composite,examples)
      Ripper::SexpBuilder.new(
        %Q{
        def function(var0)
          #{composite.to_ruby(examples.scope)}
        end
      }).parse      
    end

  end

end