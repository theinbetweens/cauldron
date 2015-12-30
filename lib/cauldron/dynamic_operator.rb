module Cauldron

  class DynamicOperator

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