module Cauldron

  class VarCollectOperator

    def initialize(indexes)
      @indexes = indexes
    end

    def to_ruby(variables)
      Sorcerer.source self.to_sexp([],variables)
    end

    def to_sexp(operators, variables)
      if operators.empty?
        return [:program, [:stmts_add, [:stmts_new], [:assign, [:var_field, [:@ident, "var1"]], [:method_add_block, [:call, [:vcall, [:@ident, variables[@indexes[0]]]], :".", [:@ident, "collect"]], [:do_block, [:block_var, [:params, [[:@ident, "x"]], nil, nil, nil, nil, nil, nil], false], [:stmts_add, [:stmts_new], [:var_ref, [:@ident, "x", [3, 2]]]]]]]]]
      else
        return [:program, [:stmts_add, [:stmts_new], [:assign, [:var_field, [:@ident, "var1"]], [:method_add_block, [:call, [:vcall, [:@ident, variables[@indexes[0]]]], :".", [:@ident, "collect"]], [:do_block, [:block_var, [:params, [[:@ident, "x"]], nil, nil, nil, nil, nil, nil], false], [:stmts_add, [:stmts_new], operators.first.build([], variables.push('x')) ]]]]]]
      end
    end

    def build(operators, variables = [])
      to_sexp(operators, variables)
    end    

  end

end