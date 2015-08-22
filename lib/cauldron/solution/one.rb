# def function(var0)
#   var0.collect { |x| x * 2 }
# end

module Cauldron::Solution

  class One

    def initialize

    end

    def successful?(problem)
      return true if problem[:arguments].first * 2 == problem[:response]    
      false    
    end

    def to_ruby
      sexp =
      [:method_add_block, 
        [:call, 
          [:vcall, 
            [:@ident, "var0"]
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
              :stmts_add, 
              [:stmts_new],
              [
                :binary, 
                [:var_ref, [:@ident, "x"]],
                :*,
                [:@int, "2"]
              ]
          ]
        ]
      ] 
      Sorcerer.source(sexp)
    end

  end

end