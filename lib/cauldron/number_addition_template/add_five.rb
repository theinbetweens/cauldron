module Cauldron

  module NumberAdditionTemplate

    class AddFive

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
          return false
        end
        return true
   
      end

      def to_sexp(scope, children)
        first_variable = 'var'+@indexes[0].to_s
        #binding.pry
        #'var0 + 5'
        #''
        puts %Q{#{first_variable} + 5}
        Ripper::SexpBuilder.new(%Q{#{first_variable} + 5}).parse
      end

      def clone_statement
        # TODO Need to clone the sexp methods
        # o = DynamicOperator.new(@information, @sexp_methods)
        # o.instance_eval(Sorcerer.source(@sexp_methods, indent: true))
        # o
        self.class.new(@indexes.clone)
      end

      def to_ruby(scope, operators)
        Sorcerer.source to_sexp(scope, operators)
      end  

      def branch?
        false
      end              

    end

  end

end