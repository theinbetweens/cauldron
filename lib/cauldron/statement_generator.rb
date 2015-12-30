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

        def build(children, scope)
          to_sexp(scope)
        end

        def init(indexes)
          o = self.class.new(@information,@sexp_methods)
          o.indexes = indexes
          o.instance_eval(Sorcerer.source(@sexp_methods, indent: true))
          o.close
          o
        end

        def instances(histories, composite, examples) 
          # TEMP
          raise StandardError.new('Examples should be an example') unless examples.class == ExampleSet

          res = Cauldron::Solution::Composite.new(
            [ Tree::TreeNode.new("CHILD1", self.init([0]) ) ]
          )
          unless self.init([0]).realizable?(res, examples)
            return []
          end

          results = [
            Cauldron::ActualizedComposite.new(
              Cauldron::Solution::Composite.new(
                [ Tree::TreeNode.new("CHILD1", self.init([0]) ) ]
              ),
              examples
            )
          ]
          
          # TODO Predict the validatity of the instances
          # TODO Validate the prediction
          # TODO Update code to better predict
          results
        end

        def realizable?(composite, examples)
          o = Object.new
          composite.to_ruby(examples.scope)
          sexp = rip(composite,examples) 
          o.instance_eval(Sorcerer.source(sexp, indent: true))
          begin
            o.function(examples.examples.first.arguments.first)
          rescue NoMethodError
            # TODO Need to record failing tests here
            return false
          end
          true
        end

        def to_tracking_sexp(operators, scope, caret)
          raise StandardError.new('instance closed') unless @closed
          to_sexp(scope)
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