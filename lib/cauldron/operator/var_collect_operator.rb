module Cauldron

  class VarCollectOperator

    def initialize(indexes)
      @indexes = indexes
    end

    def to_ruby(variables)
      Sorcerer.source self.to_sexp([],variables)
    end

    def to_sexp(operators, scope)
      if operators.empty?
        return [:stmts_add, [:stmts_new], [:assign, [:var_field, [:@ident, scope.new_variable! ]], [:method_add_block, [:call, [:vcall, [:@ident, scope[@indexes[0]]]], :".", [:@ident, "collect"]], [:do_block, [:block_var, [:params, [[:@ident, "x"]], nil, nil, nil, nil, nil, nil], false], [:stmts_add, [:stmts_new], [:var_ref, [:@ident, "x", [3, 2]]]]]]]]
      else
        return [:stmts_add, [:stmts_new], [:assign, [:var_field, [:@ident, scope.new_variable! ]], [:method_add_block, [:call, [:vcall, [:@ident, scope[@indexes[0]]]], :".", [:@ident, "collect"]], [:do_block, [:block_var, [:params, [[:@ident, "x"]], nil, nil, nil, nil, nil, nil], false], [:stmts_add, [:stmts_new], operators.first.build([], scope.push('x')) ]]]]]
      end
    end

    def build(operators, variables = [])
      to_sexp(operators, variables)
    end    

  end

end