module Cauldron

  class VarCollectOperator

    def initialize(indexes)
      @indexes = indexes
    end

    def to_ruby(variables)
      Sorcerer.source self.to_sexp([],variables)
    end

    def to_sexp(operators, scope)
      scope_var = scope.new_variable!
      second_scope_var = scope.new_variable!
      if operators.empty?
        return [:stmts_add, [:stmts_new], [:assign, [:var_field, [:@ident, scope_var ]], [:method_add_block, [:call, [:vcall, [:@ident, scope[@indexes[0]]]], :".", [:@ident, "collect"]], [:do_block, [:block_var, [:params, [[:@ident, second_scope_var]], nil, nil, nil, nil, nil, nil], false], [:stmts_add, [:stmts_new], [:var_ref, [:@ident, second_scope_var]]]]]]]
      else
        return [:stmts_add, [:stmts_new], [:assign, [:var_field, [:@ident, scope_var ]], [:method_add_block, [:call, [:vcall, [:@ident, scope[@indexes[0]]]], :".", [:@ident, "collect"]], [:do_block, [:block_var, [:params, [[:@ident, second_scope_var]], nil, nil, nil, nil, nil, nil], false], [:stmts_add, [:stmts_new], operators.first.build([], scope) ]]]]]
      end
    end

    def build(operators, scope)
      to_sexp(operators, scope)
    end    

  end

end