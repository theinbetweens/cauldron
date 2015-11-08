module Cauldron

  class VarCollectOperator

    def initialize(indexes)
      @indexes = indexes
    end

    def to_ruby(variables)
      Sorcerer.source self.to_sexp(variables)
    end

    def to_sexp(variables)
      [:program, [:stmts_add, [:stmts_new], [:assign, [:var_field, [:@ident, "var1"]], [:method_add_block, [:call, [:vcall, [:@ident, variables[@indexes[0]]]], :".", [:@ident, "collect"]], [:do_block, [:block_var, [:params, [[:@ident, "x", [2, 24]]], nil, nil, nil, nil, nil, nil], false], [:stmts_add, [:stmts_new], [:var_ref, [:@ident, "x", [3, 2]]]]]]]]]
    end

  end

end