class ArrayCollect

  def initialize
    
  end

  def to_ruby(operator = nil)
    #sexp = Ripper::SexpBuilder.new(%q{var0.collect { |x| x * 2 }}).parse
    block_sexp = [:var_ref, [:@ident, "x"]]
    unless operator.nil?
      block_sexp = operator.to_sexp('x')
    end
    sexp = 
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
          [:stmts_add, [:stmts_new], block_sexp
        ]
      ]
    ] 
    Sorcerer.source(sexp)
  end

end