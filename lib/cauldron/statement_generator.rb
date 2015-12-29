module Cauldron

  class StatementGenerator

    def build(instance,dynamic_methods)
      dynamic_methods.collect do |x|
        build_class(instance,x)
      end
    end

    def build_class(instance, dynamic_method)
      sexp = Ripper::SexpBuilder.new(%Q{
        def to_ruby(variables)
          Sorcerer.source self.to_sexp(variables)
        end

        def to_sexp(scope)
          [:call,
            [:vcall, [:@ident, scope[@indexes[0]] ]],
            :".",
            [:@ident, "#{dynamic_method}"]
          ]
        end

        def build(indexes)
          o = self.class.new(@information,@sexp_methods)
          o.indexes = indexes
          o.instance_eval(Sorcerer.source(@sexp_methods, indent: true))
          o.close
          o
        end

        def instances(histories, composite, examples) 
          [
            Cauldron::ActualizedComposite.new(
              Cauldron::Solution::Composite.new(
                [ Tree::TreeNode.new("CHILD1", self.build([0]) ) ]
              ),
              examples
            )
          ]
        end
        def to_tracking_sexp(operators, scope, line, depth, total_line)
          []
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