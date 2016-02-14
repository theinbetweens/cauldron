module Cauldron

  class StatementGenerator

    # Build appropriate classes that can build appropriate instances - instances 
    # must have the constants
    def build(instance,dynamic_methods,declare_variable=false)
      dynamic_methods.collect do |x|
        build_class(instance,x)
      end
    end

    def sexp_method_to_ruby(instance, dynamic_method)
      #Ripper::SexpBuilder.new(%Q{
      %Q{
        def to_ruby(scope, operators)
          Sorcerer.source self.to_sexp(scope, operators)
        end
      #}
    end

    def method_to_sexp(instance, dynamic_method)
      if instance.send(dynamic_method).class == Enumerator
        %Q^
          def to_sexp(scope, operators)
            scope_var = scope.new_variable!
            scope_var_two = scope.new_variable!
            dynamic_method = '#{dynamic_method}'
            
            a = "\#{scope_var} = \#{scope[@indexes[0]]}.\#{dynamic_method} do |\#{scope_var_two}|"+"\n"
            a += operators.collect {|x| x.content.to_ruby(scope, x.children) }.join("\n")
            a += "\n"+"end"+"\n"
            puts a
            Ripper::SexpBuilder.new(a).parse

          end
        ^
      else
        %Q{
          def to_sexp(scope, operators)
            [:call,
              [:vcall, [:@ident, scope[@indexes[0]] ]],
              :".",
              [:@ident, "#{dynamic_method}"]
            ]
          end        
        }
      end
    end

    def branch_method(instance, dynamic_method)
      if instance.send(dynamic_method).class == Enumerator
        return %q{
          def branch?
            true
          end          
        }
      end
      %q{
        def branch?
          false
        end          
      }
    end

    def build_class(instance, dynamic_method)
      res = %Q{

        #{sexp_method_to_ruby(instance, dynamic_method)}

        #{method_to_sexp(instance, dynamic_method)}

        #{branch_method(instance, dynamic_method)}

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

        def instances(histories, composite, examples, insert_points)

          # TEMP
          unless examples.class == ExampleSet
            raise StandardError.new('Examples should be an example')
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

            composites = self.context_instances(contexts)

            # scopes = scopes_at_point(point)

            composites.each do |x|
              if contexts.all? do |context|
                x.context_realizable?(context)
              end
              puts '=====|||||||||'
              #puts point.inspect
              #puts x.to_ruby(Cauldron::Scope.new(['var0', 'var1', 'var2', 'var3', 'var4']))

              #if x.to_ruby(Cauldron::Scope.new(['var0', 'var1', 'var2', 'var3', 'var4'])).match(/chop/)
                # pending.pry
                # binding.pry
                # puts x.to_ruby(Cauldron::Scope.new(['var0', 'var1', 'var2', 'var3', 'var4']))
                # composite.operators[0].content.to_ruby(Cauldron::Scope.new(['var0']))
                # examples
                # point
              #end
                
              results << extend_actualized_composite(x, composite, examples, point)
            end
          end

          end
          return results

          # ------

          # insert_points.each do |point|
          #   res = Cauldron::Solution::Composite.new(
          #     [ Tree::TreeNode.new("CHILD1", self.init([0]) ) ]
          #   )
          #   unless self.init([0]).realizable?(histories, point)
          #     return []
          #   end
          # end

          # results = [
          #   Cauldron::ActualizedComposite.new(
          #     Cauldron::Solution::Composite.new(
          #       [ Tree::TreeNode.new("CHILD1", self.init([0]) ) ]
          #     ),
          #     examples
          #   )
          # ]
          
          # TODO Predict the validatity of the instances
          # TODO Validate the prediction
          # TODO Update code to better predict
          results
        end

        def realize(params)
          o = Object.new
          o.instance_eval(rip2)
          o.function(*params.values)
        end

        def realizable?(histories, point)
          parameters = histories.variable_permutations(@indexes.length)

          parameters.each do |params|
            begin
              realize(params)
            rescue => e
              failed_uses.push(histories)
              return false
            end
          end
          true          
        rescue => e
          # TODO GENERATE RSPEC TEST with arguments
        end

        def to_tracking_sexp(operators, scope, caret)
          raise StandardError.new('statement has been instance closed') unless @closed
          to_sexp(scope)
        end
      }
      
      sexp = Ripper::SexpBuilder.new(res).parse

      information = { constants: false }
      
      o = DynamicOperator.new(information, sexp)
      o.instance_eval(Sorcerer.source(sexp, indent: true))
      o
    end

  end

end

# TODO stacking mulitple rescues does not work
# realizable?

# def realizable?(composite, examples)
#   o = Object.new
#   composite.to_ruby(examples.scope)
#   sexp = rip(composite,examples) 
#   o.instance_eval(Sorcerer.source(sexp, indent: true))
#   begin
#     o.function(examples.examples.first.arguments.first)
#   rescue NoMethodError
#     # TODO Need to record failing tests here
#     failed_uses << { composite:composite, examples: examples}
#     return false
#   end
#   true
# end