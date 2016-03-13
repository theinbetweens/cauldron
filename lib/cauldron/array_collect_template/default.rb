module Cauldron

  module ArrayCollectTemplate

    class Default

      attr_reader :indexes

      def initialize(indexes)
        @indexes = indexes
      end      

      def context_realizable?(context)
        
        vars = context.keys.select {|x| x.match(/var\d/) }
        var_names = vars.collect(&:to_s)
        
        first_variable = 'var'+@indexes[0].to_s

        a = %Q{
        def function(#{first_variable})
          #{Sorcerer.source(to_sexp(Cauldron::Scope.new(var_names), []), indent: true)}
        end
        }       
        
        o = Object.new
        o.instance_eval(a)

        begin
          #o.function(*vars.collect {|x| context[x] })  
          o.function context[first_variable.to_sym]
        rescue NoMethodError => e
          return false
        rescue StandardError => e
          puts e
        end
        return true
   
      end

      def to_sexp(scope, children)
        scope_var = scope.new_variable!
        first_variable = 'var'+@indexes[0].to_s
        [:method_add_block, 
          [:call, 
            [:vcall, 
              # [:@ident, scope[@indexes[0]] ]], 
              [:@ident, first_variable ]], 
              :".", 
              [:@ident, "collect"]
          ], 
          unless children.empty?
            [:brace_block, 
              [:block_var, 
                [:params, [[:@ident, scope_var]]]], 
                [
                  :stmts_add, 
                  [:stmts_new], 
                  # TODO Shouild probably be passing the children through here
                  children.first.content.to_sexp(scope, [])
                ]
            ]
          else
            [:brace_block, 
              [:block_var, 
                [:params, [[:@ident, scope_var]]], 
                [:stmts_add, [:stmts_new]]
              ]
            ]        
          end
        ]    
      end

      def to_ruby(scope, operators)
        Sorcerer.source to_sexp(scope, operators)
      end

      def clone_statement
        # TODO Need to clone the sexp methods
        # o = DynamicOperator.new(@information, @sexp_methods)
        # o.instance_eval(Sorcerer.source(@sexp_methods, indent: true))
        # o
        self.class.new(@indexes.clone)
      end

      def branch?
        true
      end                   

    end

  end

end