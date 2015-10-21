#module Cauldron::Operator

  class ToSOperator

    def intialize(indexes)
      @indexes = indexes
    end

    def build(operators, variables = [])
      # [:method_add_block, 
      #   [:call, 
      #     [:vcall, 
      #       [:@ident, "var0"]], 
      #       :".", 
      #       [:@ident, "collect"]
      #   ], 
      #   [:brace_block, 
      #     [:block_var, 
      #       [:params, [[:@ident, "x"]]]], 
      #       [:stmts_add, [:stmts_new], operators.first.build('x')
      #     ]
      #   ]
      # ]    
    end

  end

#end