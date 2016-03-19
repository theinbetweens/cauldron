module Cauldron

  class StatementGenerator

    # Build appropriate classes that can build appropriate instances - instances 
    # must have the constants
    def build(instance,dynamic_methods,declare_variable=false)
      dynamic_methods.collect do |x|
        build_template(instance,x)
      end
    end

    def build_template(instance, dynamic_method)
      build_class(instance, dynamic_method)
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

            first_variable = 'var'+@indexes[0].to_s
            
            a = "\#{scope_var} = \#{first_variable}.\#{dynamic_method} do |\#{scope_var_two}|"+"\n"
            a += operators.collect {|x| x.content.to_ruby(scope, x.children) }.join("\n")
            a += "\n"+"end"+"\n"
            puts a
            Ripper::SexpBuilder.new(a).parse

          end
        ^
      else
        %Q{
          def to_sexp(scope, operators)
            first_variable = 'var'+@indexes[0].to_s
            [:call,
              [:vcall, [:@ident, first_variable ]],
              :".",
              [:@ident, "#{dynamic_method}"]
            ]
          end        
        }
      end
    end

    def requires_arguments?(instance, dynamic_method)
      instance.send(dynamic_method)
      false
    rescue ArgumentError => e
      true
    end

    def expects_block?(instance, dynamic_method)
      instance.send(dynamic_method).class == Enumerator
    end

    def branch_method(instance, dynamic_method)
      if requires_arguments?(instance, dynamic_method)
        return %q{
          def branch?
            false
          end
        }        
      end

      if expects_block?(instance, dynamic_method)
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

    def template_sexp(instance, dynamic_method)

      res = %Q{

        #{sexp_method_to_ruby(instance, dynamic_method)}

        #{method_to_sexp(instance, dynamic_method)}

        #{branch_method(instance, dynamic_method)}

        def self.instances(histories, composite, examples, insert_points)

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
      Ripper::SexpBuilder.new(res).parse
    end

    def dynamic_template_name(instance, dynamic_method)
      dynamic_method_name = dynamic_method.to_s.gsub(/\+/,'Add')
      dynamic_name = ('Dynamic'+'_'+instance.class.to_s+'_'+dynamic_method_name.to_s).camelize
      dynamic_name+'Template'
    end

    def build_class(instance, dynamic_method)
      sexp = template_sexp(instance, dynamic_method)
      information = { constants: false }
      
      template_name = dynamic_template_name(instance, dynamic_method)

      # http://ruby-doc.org/core-2.3.0/Class.html
      # http://stackoverflow.com/questions/4113479/dynamic-class-definition-with-a-class-name
      unless Object.const_defined? template_name
        c = Object.const_set(
              template_name,  
              Class.new do

                attr_reader :indexes, :dynamic_name, :sexp_methods
                attr_accessor :failed_uses                

                def initialize(information, sexp_methods)
                  @information, @sexp_methods = information, sexp_methods
                  @failed_uses = []
                end  

                # NOTE: These theses classes define the constants
                def statement_classes

                  # Find the constants
                  c = Object.const_set(
                    self.class.to_s+rand(4000000).to_s,
                    Class.new do

                      include Cauldron::Operator
                      include Cauldron::DynamicOperatorModule   

                      attr_reader :indexes        
                      attr_accessor :failed_uses     

                      def initialize(indexes)
                        @indexes = indexes
                        @failed_uses = []
                      end

                      def self.context_instances(contexts)
                        temp = []
                        contexts.each do |context|
                          temp << context.keys.collect(&:to_s).select {|x| x.match(/var\d/) }
                        end
                        results = temp.flatten.uniq
                        
                        variable_numbers = results.collect { |x| x.match(/var(\d+)/)[1] }
                        # TODO Presumes that only one variable is passed
                        variable_numbers.collect { |x| new([x.to_i])}
                      end 

                      def self.extend_actualized_composite(x, container, examples, point)
                        cloned_container = container.clone_solution
                        cloned_container.add_statement_at(x, point)
                        cloned_container
                        Cauldron::ActualizedComposite.new(cloned_container, examples)
                      end  

                      def rip2
                        %Q{
                        def function(var0)
                          #{Sorcerer.source(to_sexp(Cauldron::Scope.new(['var0']),[]), indent: true)}
                        end
                        }
                      end

                    end
                  )
                  c.class_eval(Sorcerer.source(sexp_methods, indent: true))
                  [c]
                end                 

              end
            )
        
        
        a = c.new(information, sexp.clone)

        return a.statement_classes.first        
      else
        a = eval(template_name).new(information, sexp.clone)
        return a.statement_classes.first
      end

      raise StandardError.new('Should not get here')
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