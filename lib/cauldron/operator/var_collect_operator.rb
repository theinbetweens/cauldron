# frozen_string_literal: true

module Cauldron
  class VarCollectOperator
    def initialize(indexes)
      @indexes = indexes
    end

    def to_ruby(contents, variables)
      Sorcerer.source to_sexp(contents, variables)
    end

    def to_sexp(scope, operators)
      scope_var = scope.new_variable!
      second_scope_var = scope.new_variable!
      if operators.empty?
        return [:stmts_add, [:stmts_new], [:assign, [:var_field, [:@ident, scope_var]], [:method_add_block, [:call, [:vcall, [:@ident, scope[@indexes[0]]]], :".", [:@ident, 'collect']], [:do_block, [:block_var, [:params, [[:@ident, second_scope_var]], nil, nil, nil, nil, nil, nil], false], [:stmts_add, [:stmts_new], [:var_ref, [:@ident, second_scope_var]]]]]]]
      else
        return [:stmts_add, [:stmts_new], [:assign, [:var_field, [:@ident, scope_var]], [:method_add_block, [:call, [:vcall, [:@ident, scope[@indexes[0]]]], :".", [:@ident, 'collect']], [:do_block, [:block_var, [:params, [[:@ident, second_scope_var]], nil, nil, nil, nil, nil, nil], false], [:stmts_add, [:stmts_new], operators.first.content.build([], scope)]]]]]
      end
    end

    def build(children, scope)
      to_sexp(scope, children)
    end
  end
end
