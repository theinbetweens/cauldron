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
      # sexp = Ripper::SexpBuilder.new(
      #         'def function('+variables.join(',')+');'+relationship.to_ruby(variables)+"; end").parse
      sexp = Ripper::SexpBuilder.new(
%Q{
def function(var0)
  #{Sorcerer.source(tracking_sexp(scope,0,0,0)) }
end
}).parse
      Cauldron::Tracer.new(sexp)
    end

    def tracking_sexp(scope, line, depth, total_line)
      #binding.pry
      [:bodystmt,
        [:stmts_add,
          [:stmts_new],
          tracking(line,depth,total_line)
        ]
      ]
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

    def tracking(line, depth, total_line)
      [:program,
       [:stmts_add,
        [:stmts_new],
        [:method_add_arg,
         [:fcall, [:@ident, "record", [2, 0]]],
         [:arg_paren,
          [:args_add_block,
           [:args_add,
            [:args_add,
             [:args_add,
              [:args_add, [:args_new], [:@int, line, [2, 7]]],
              [:@int, depth, [2, 9]]],
             [:@int, total_line, [2, 11]]],
            [:method_add_block,
             [:call,
              [:method_add_block,
               [:call,
                [:vcall, [:@ident, "local_variables", [2, 13]]],
                :".",
                [:@ident, "reject", [2, 29]]],
               [:brace_block,
                [:block_var,
                 [:params,
                  [[:@ident, "foo", [2, 38]]],
                  nil,
                  nil,
                  nil,
                  nil,
                  nil,
                  nil],
                 false],
                [:stmts_add,
                 [:stmts_new],
                 [:binary,
                  [:var_ref, [:@ident, "foo", [2, 43]]],
                  :==,
                  [:symbol_literal, [:symbol, [:@ident, "_", [2, 51]]]]]]]],
              :".",
              [:@ident, "collect", [2, 54]]],
             [:brace_block,
              [:block_var,
               [:params, [[:@ident, "bar", [2, 65]]], nil, nil, nil, nil, nil, nil],
               false],
              [:stmts_add,
               [:stmts_new],
               [:array,
                [:args_add,
                 [:args_add, [:args_new], [:var_ref, [:@ident, "bar", [2, 71]]]],
                 [:method_add_arg,
                  [:fcall, [:@ident, "eval", [2, 76]]],
                  [:arg_paren,
                   [:args_add_block,
                    [:args_add,
                     [:args_new],
                     [:call,
                      [:var_ref, [:@ident, "bar", [2, 81]]],
                      :".",
                      [:@ident, "to_s", [2, 85]]]],
                    false]]]]]]]]],
           false]]]]]
    end

    def successful?(problem)

      # # TODO track the parameters of the operator
      # operators.trace(problem)

      # # TODO For now just evalute the code
      # return true if problem[:arguments].first == problem[:response]    
      # false    
      pt = PryTester.new

      args = problem[:arguments]
      variables = (0...args.length).collect {|x| 'var'+x.to_s}
      a = [
        'def function('+variables.join(',')+');'+self.to_ruby(variables)+"; end", 
        'function('+problem[:arguments].collect {|x| to_programme(x) }.join(',')+')'
      ]
      
      res = pt.eval(
        ['def function('+variables.join(',')+');'+self.to_ruby(variables)+"; end", 'function('+problem[:arguments].collect {|x| to_programme(x) }.join(',')+')']
      )

      #problem[:response] == Pry::Code.new(self.to_ruby)
      problem[:response] == res
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