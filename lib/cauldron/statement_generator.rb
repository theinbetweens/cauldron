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
          
          results
        end

        def realize(params)
          o = Object.new
          o.instance_eval(rip2)
          o.function(*params.values)
        end
     
      }
      
      sexp = Ripper::SexpBuilder.new(res).parse

      information = { constants: false }
      
      o = DynamicOperator.new(information, sexp)
      o.instance_eval(Sorcerer.source(sexp, indent: true))


      puts 'Creating class'
      
      # puts '----------------------'
      # a = puts(instance.class)
      # puts a
      # puts dynamic_method

      # ios = IO.new STDOUT.fileno
      # ios.write "ZetCode\n"
      # ios.close

      # http://ruby-doc.org/core-2.3.0/Class.html
      dynamic_name = ('Dynamic'+'_'+instance.class.to_s+'_'+dynamic_method.to_s).camelize
      
      # http://stackoverflow.com/questions/4113479/dynamic-class-definition-with-a-class-name
      unless Object.const_defined? dynamic_name
        # c = Object.const_set(
        #       dynamic_name, 
        #       Class.new do 

        #         include Cauldron::Operator

        #         def method1() 
        #           42 
        #         end            

        #       end
        # )
        c = Object.const_set(
              dynamic_name, 
              #DynamicOperator.new(information, sexp) do 
              Class.new do

                include Cauldron::Operator
                include Cauldron::DynamicOperatorModule

                attr_reader :indexes
                attr_accessor :failed_uses                

                def initialize(information, sexp_methods)
                  @information, @sexp_methods = information, sexp_methods
                  @failed_uses = []
                  @closed = false
                end

                def method1() 
                  42 
                end

                # def initialize(information, sexp_methods)
                #   @information, @sexp_methods = information, sexp_methods
                #   @failed_uses = []
                #   @closed = false
                # end                            

              end
        )
        
        #binding.pry


        # c.class_eval %q{
        #   def self.context_instances(contexts)
        #     results = []
        #     contexts.each do |context|
        #       results << context.keys.collect(&:to_s).select {|x| x.match(/var\d/) }
        #     end
        #     results = results.flatten.uniq
        #     variable_numbers = results.collect { |x| x.match(/var(\d+)/)[1] }
        #     variable_numbers.collect { |x| init([x.to_i])}
        #   end
        # }

        #a = Object.const_set(dynamic_name, Cauldron::DynamicOperator.new(information, sexp) { def method1() 42 end })
        #o.instance_eval(Sorcerer.source(sexp, indent: true))
        #binding.pry
        
        #c.new(information, sexp)
        #a = c.new
        #a.instance_eval(Sorcerer.source(sexp, indent: true))
        #return a
        a = c.new(information, sexp)
        a.instance_eval(Sorcerer.source(sexp, indent: true))
        #c.instance_eval(Sorcerer.source(sexp, indent: true))
        return a
        # ClassName.new.method1 #=> 42        
      else
        a = eval(dynamic_name).new(information, sexp)
        a.instance_eval(Sorcerer.source(sexp, indent: true))
        return a
      end

      return a
      #puts dynamic_name.camelize   
      #puts '----------------------'

      # Alternativly: 
      # http://stackoverflow.com/questions/4113479/dynamic-class-definition-with-a-class-name
      # dynamic_name = "ClassName"
      # Object.const_set(dynamic_name, Class.new { def method1() 42 end })
      # ClassName.new.method1 #=> 42

      # o.instance_eval do 
      #   #"include Cauldron::Operator"
      #   %q{
      #     def context_instances(contexts)
      #       results = []
      #       contexts.each do |context|
      #         results << context.keys.collect(&:to_s).select {|x| x.match(/var\d/) }
      #       end
      #       results = results.flatten.uniq
      #       variable_numbers = results.collect { |x| x.match(/var(\d+)/)[1] }
      #       variable_numbers.collect { |x| init([x.to_i])}
      #     end            
      #   }
      # end
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