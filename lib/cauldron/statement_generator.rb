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
      %Q{
        def to_ruby(scope, operators)
          Sorcerer.source self.to_sexp(scope, operators)
        end
      #}
    end

    def method_to_sexp(instance, dynamic_method)

      # Does it expect arguments?
      begin
        instance.send(dynamic_method)
      rescue ArgumentError => e
        
        number_of_arguments = e.message.match(/(\d+)\)/)[1].to_i
        to_sexp_method = %Q^
          def to_sexp(scope, operators)
            Ripper::SexpBuilder.new("\#{scope[@indexes[0]]} + \#{constant}").parse 
          end
        ^
        return to_sexp_method
      end

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
          # TODO Include this module
          # o.instance_eval do
          #   include Cauldron::Operator
          # end
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

            composites = context_instances(contexts)

            composites.each do |x|
              if contexts.all? do |context|
                x.context_realizable?(context)
              end
              results << extend_actualized_composite(x, composite, examples, point)
            end
          end

          end
          
          results
        end
     
      }
      
      sexp = Ripper::SexpBuilder.new(res).parse

      information = { constants: false }

      # http://ruby-doc.org/core-2.3.0/Class.html
      dynamic_name = ('Dynamic'+'_'+instance.class.to_s+'_'+dynamic_method.to_s).camelize
      dynamic_template_name = dynamic_name+'Template'
      
      # http://stackoverflow.com/questions/4113479/dynamic-class-definition-with-a-class-name
      unless Object.const_defined? dynamic_template_name
        c = Object.const_set(
              dynamic_template_name, 
              #DynamicOperator.new(information, sexp) do 
              Class.new do

                include Cauldron::Operator
                include Cauldron::DynamicOperatorModule

                attr_reader :indexes, :dynamic_name
                attr_accessor :failed_uses                

                def initialize(information, sexp_methods)
                  @information, @sexp_methods = information, sexp_methods
                  @failed_uses = []
                  @closed = false
                end

                def method1() 
                  42 
                end     

                def statement_classes
                  [
                    c = Object.const_set(
                      self.class.to_s+rand(4000000).to_s,
                      Class.new do

                        def initialize(indexes)
                          puts 'WHO WOULD HAVE THOUGHT IT'
                        end

                        def method_embed
                          'askdlsadksla'
                        end

                      end
                    )
                  ]
                end                 

              end
            )
        
        a = c.new(information, sexp)
        a.instance_eval(Sorcerer.source(sexp, indent: true))

        #binding.pry
        #c.instance_eval(Sorcerer.source(sexp, indent: true))
        return a
        # ClassName.new.method1 #=> 42        
      else
        a = eval(dynamic_template_name).new(information, sexp)
        a.instance_eval(Sorcerer.source(sexp, indent: true))
        return a
      end

      return a
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