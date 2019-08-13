# frozen_string_literal: true

class ConcatOperator
  include Cauldron::Operator

  def initialize(indexes)
    @indexes = indexes
    @constant = 'bar'
  end

  def self.viable?(arguments, response)
    return false unless arguments.all? { |x| x.is_a?(String) }
    return false unless response.is_a?(String)

    # TODO: - Only accpets one argument
    true
  end

  def self.find_constants(problems)
    problems.examples.each_with_object([]) do |x, total|
      result = x.response.gsub(Regexp.new('^' + x.arguments.first), '')
      total << result unless result == x.response
    end.uniq
  end

  def self.uses_constants?
    true
  end

  def self.uses_block?
    false
  end

  def branch?
    false
  end

  # Operator for "x.concat("bar")"
  def successful?(problem)
    return true if (problem[:arguments].first + @constant) == problem[:response]

    false
  end

  def to_ruby(scope, operators)
    Sorcerer.source to_sexp(scope, operators)
  end

  def build(_operators, scope)
    to_sexp(scope)
  end

  def to_sexp(_scope, _operators)
    first_variable = 'var' + @indexes[0].to_s
    [:program,
     [:stmts_add,
      [:stmts_new],
      [:method_add_arg,
       [:call,
        [:vcall, [:@ident, first_variable]],
        :".",
        [:@ident, 'concat']],
       [:arg_paren,
        [:args_add_block,
         [:args_add,
          [:args_new],
          [:string_literal,
           [:string_add, [:string_content], [:@tstring_content, @constant]]]],
         false]]]]]
  end
end
