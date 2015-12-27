module Cauldron::Solution

  class Composite

    attr_reader :operators

    def initialize(children)
      @operators = children
    end

    def record(example)
      # TODO params passed twice - and example not used at all
      insert_tracking(example.params).process(example)
    end

    def insert_tracking(params)
      scope = Cauldron::Scope.new(['var0'])
      sexp = Ripper::SexpBuilder.new(
%Q{
def function(var0)
  #{Sorcerer.source(tracking_sexp(scope,0,0,0)) }
end
}).parse
      Cauldron::Tracer.new(sexp)
    end

    def tracking_sexp(scope, line, depth, total_line)
      
      if operators.empty?
        sexp = [:bodystmt,
          [:stmts_add,
            [:stmts_new]
          ],
          Cauldron::Tracer.tracking(operators.length,depth,operators.length)
        ]        
      else
        sexp = [:bodystmt,
          [:stmts_add,
            [:stmts_new],
            operators.first.content.to_tracking_sexp(operators.first.children, scope, line, depth+1, total_line),
            # *operators.collect do |x|
            #   x.content.to_sexp(x.children, scope)
            # end,
          ],
          Cauldron::Tracer.tracking(operators.length,depth,operators.length)
        ]
      end
      sexp
      #pp Sorcerer.source(sexp, indent: true)


      # [:bodystmt,
      #   [:stmts_add,
      #     [:stmts_new],
      #     operators.first.content.to_sexp(operators.first.children, scope),
      #     # *operators.collect do |x|
      #     #   x.content.to_sexp(x.children, scope)
      #     # end,
      #     Cauldron::Tracer.tracking(line,depth,total_line)
      #   ]
      # ]
      #[:program, tracking]
    end

    def sexp(variables=[])
      #number_of_lines = operators.length
      
      #first = operators[0]
      first = operators.first
      
      #inner = add_first_statement( first.content.build(first.children.first, variables) )
      inner = add_first_statement( 
                first.content.build(
                  first.children, variables
                ) 
              )

      second = operators[1]
      
      if second.nil?
        results = inner
      else
        results = add_statement(
                    second.content.build(second.children, variables),
                    inner
                  )
      end
      
      # TODO Not sure why this is needed just yet
      [:program, results]
    end

    def to_ruby(scope)
      Sorcerer.source(sexp(scope))
    end

    def add_first_statement(statement)
      [:stmts_add, [:stmts_new], statement]
    end

    def add_statement(statement, inner)
      [:stmts_add, inner, statement]
    end

    def solution?(problems)
      false
    end

    def successful?(problem)

      # # TODO track the parameters of the operator
      # operators.trace(problem)

      # # TODO For now just evalute the code
      # return true if problem[:arguments].first == problem[:response]    
      # false    
      pt = PryTester.new

      args = problem.arguments
      variables = problem.params #(0...args.length).collect {|x| 'var'+x.to_s}
      a = [
        'def function('+variables.join(',')+');'+self.to_ruby(variables)+"; end", 
        'function('+problem.arguments.collect {|x| to_programme(x) }.join(',')+')'
      ]
      
      res = pt.eval(
        ['def function('+variables.join(',')+');'+self.to_ruby(variables)+"; end", 'function('+problem.arguments.collect {|x| to_programme(x) }.join(',')+')']
      )

      #problem[:response] == Pry::Code.new(self.to_ruby)
      problem.response == res
    end

    def to_programme(value)
      if value.kind_of?(String)
        return %Q{'#{value}'}
      end
      value.to_s
    end

    # TODO Add a safety evalutor
    
  end

end