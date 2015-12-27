module Cauldron

  class StatementGenerator

    def build(instance,dynamic_methods)
      dynamic_methods.collect do |x|
        build_class(instance,x)
      end
    end

    def build_class(instance, dynamic_method)
      sexp = Ripper::SexpBuilder.new(%q{
        def to_ruby(variables)
          Sorcerer.source self.to_sexp(variables)
        end
        def build(indexes)
          o = self.class.new(@information,@sexp_methods)
          o.indexes = indexes
          o.close
          o
        end        
      }).parse

      information = {
        constants: false
      }

      o = DynamicOperator.new(information, sexp)
      o.instance_eval(Sorcerer.source(sexp, indent: true))
      o

    end

  end

end