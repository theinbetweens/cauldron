# def function(var0)
#   var0.collect { |x| x * 2 }
# end

module Cauldron::Solution

  class One

    def initialize

    end

    def successful?(problem)
      return false unless problem.arguments.first.kind_of?(Array)
      return false unless problem.arguments.first[0] * 2 == problem.response[0]
      return false unless problem.arguments.first[1] * 2 == problem.response[1]
      true    
    end

    def to_ruby(variables)
      sexp =
      [:method_add_block, 
        [:call, 
          [:vcall, 
            [:@ident, variables[0]]
          ], 
          :".", 
          [:@ident, "collect"]
        ], 
        [:brace_block, 
          [:block_var, 
            [:params, 
              [[:@ident, "x"]]
            ]
          ], 
          [
            :binary, 
            [:var_ref, [:@ident, "x"]],
            :*,
            [:@int, "2"]
          ]
        ]
      ] 
      Sorcerer.source(sexp)
    end

  end

end