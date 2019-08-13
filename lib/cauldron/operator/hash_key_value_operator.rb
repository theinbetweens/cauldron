# frozen_string_literal: true

# http://www.ruby-doc.org/core-2.1.1/Hash.html
# hsh[key] → value
class HashKeyValueOperator
  # var0[:foo]

  def initialize(indexes)
    @indexes = indexes
    @constant = :foo
    # @constant, @indexes = constant, indexes
  end

  def self.viable?(arguments, _response)
    return false unless arguments.all? { |x| x.is_a?(Hash) }

    true
  end

  def self.uses_constants?
    true
  end

  def self.find_constants(problems)
    problems.collect { |x| x.arguments.first.keys }.flatten
  end

  def successful?(problem)
    return true if problem.arguments.first[@constant] == problem.response

    false
  end

  def to_ruby(scope, operators)
    Sorcerer.source to_sexp(scope, operators)
  end

  def to_sexp(scope, _operators)
    [:aref,
     [:vcall,
      [:@ident, scope[0]]],
     [:args_add_block,
      [
        :args_add,
        [:args_new],
        sexp_index
      ]]]
  end

  def sexp_index
    if @constant.is_a?(Symbol)
      a = [
        :symbol_literal,
        [:symbol, [:@ident, @constant]],
        [:string_add, [:@ident, @constant]]
      ]
      a
    elsif @constant.is_a?(String)
      [
        :string_literal,
        [
          :string_add,
          [:string_content],
          [:@tstring_content, @constant]
        ]
      ]
    else
      raise StandardError, 'Unknown index'
    end
  end
end
