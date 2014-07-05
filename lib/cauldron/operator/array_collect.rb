class ArrayCollect

  def initialize
    
  end

  def to_ruby(operator = nil)
    # sexp = Ripper::SexpBuilder.new(%Q{var0.collect { |x| x }}).parse
    #Sorcerer.source sexp
    # sexp = 
    # [
    #   :program, 
    #   [:stmts_add, 
    #     [:stmts_new], 
    #     [:method_add_block, 
    #       [:call, 
    #         [:vcall, 
    #           [:@ident, "var0", [1, 0]]], 
    #           :".", 
    #           [:@ident, "collect", [1, 5]]
    #       ], 
    #       [:brace_block, 
    #         [:block_var, 
    #           [:params, [[:@ident, "x", [1, 16]]], nil, nil, nil, nil], nil], 
    #           [:stmts_add, [:stmts_new], [:var_ref, [:@ident, "x", [1, 19]]]
    #         ]
    #       ]
    #     ]
    #   ]
    # ]
    sexp = 
    [
      # :program, 
      # [:stmts_add, 
      #   [:stmts_new], 
        [:method_add_block, 
          [:call, 
            [:vcall, 
              [:@ident, "var0"]], 
              :".", 
              [:@ident, "collect"]
          ], 
          [:brace_block, 
            [:block_var, 
              [:params, [[:@ident, "x"]]]], 
              [:stmts_add, [:stmts_new], [:var_ref, [:@ident, "x"]]
            ]
          ]
        ]
      # ]
    ]    
    return Sorcerer.source(sexp) if operator.nil?
    "  var0.collect { |x| #{operator.to_ruby('x')} }"+"\n"
  end

end