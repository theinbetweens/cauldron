module Cauldron

  module DynamicOperatorModule

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

    def clone_statement
      # TODO Need to clone the sexp methods
      # o = DynamicOperator.new(@information, @sexp_methods)
      # o.instance_eval(Sorcerer.source(@sexp_methods, indent: true))
      # o
      self.class.new(@indexes.clone)
    end

    # def context_instances(contexts)
    #   results = []
    #   contexts.each do |context|
    #     results << context.keys.collect(&:to_s).select {|x| x.match(/var\d/) }
    #   end
    #   results = results.flatten.uniq
    #   variable_numbers = results.collect { |x| x.match(/var(\d+)/)[1] }
    #   variable_numbers.collect { |x| init([x.to_i])}
    # end

    # def extend_actualized_composite(x, container, examples, point)
    #   cloned_container = container.clone_solution
    #   cloned_container.add_statement_at(x, point)
    #   cloned_container
    #   Cauldron::ActualizedComposite.new(cloned_container, examples)
    # end

    def context_realizable?(context)
      
      vars = context.keys.select {|x| x.match(/var\d/) }
      var_names = vars.collect(&:to_s)

      first_variable = 'var'+@indexes[0].to_s
      
      # a = %Q{
      # def function(var0)
      #   #{Sorcerer.source(to_sexp(var_names), indent: true)}
      # end
      # } 
      # a = %Q{
      # def function(var0)
      #   #{Sorcerer.source(to_sexp(Cauldron::Scope.new(var_names), []), indent: true)}
      # end
      # }     
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
      


      #o.function(*params.values)

      # a = %Q{
      # def function(var0)
      #   #{Sorcerer.source(to_sexp(Cauldron::Scope.new(['var0'])), indent: true)}
      # end
      # }      
    end

    def write_to_file(filename)
      File.open( File.join('tmp',filename), 'w+') do |file|
        file << "class DynamicOperator"+"\n"
        file << Sorcerer.source(@sexp_methods, indent: true)
        file << "\n"
        file << "end"
      end
    end

    def rip(composite,examples)
      Ripper::SexpBuilder.new(
        %Q{
        def function(var0)
          #{composite.to_ruby(examples.scope)}
        end
      }).parse      
    end

    # def to_tracking_sexp(operators, scope, caret)
    #   raise StandardError.new('statement has been instance closed') unless @closed
    #   to_sexp(scope)
    # end

    def realizable?(histories, point)
      parameters = histories.variable_permutations(@indexes.length)
      parameters.each do |params|
        begin
          realize(params)
        rescue => e
          puts e
          failed_uses.push(histories)
          return false
        end
      end
      true          
    rescue => e
      puts e
      puts e.backtrace
      # TODO GENERATE RSPEC TEST with arguments
    end

    def realize(params)
      o = Object.new
      o.instance_eval(rip2)
      o.function(*params.values)
    end    

  end

end