class ConcatOperator

  include Cauldron::Operator

  def initialize(indexes)
    @indexes = indexes
    @constant = 'bar'
  end

  def self.viable?(arguments, response)
    return false unless arguments.all? { |x| x.kind_of?(String) }
    return false unless response.kind_of?(String)
    # TODO - Only accpets one argument
    true
  end

  def self.find_constants(problems)
    problems.examples.inject([]) do |total, x| 
      result = x.response.gsub( Regexp.new('^'+x.arguments.first),'')
      total << result unless result == x.response
      total
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
    if (problem[:arguments].first + @constant) == problem[:response]
      return true
    end
    return false
  end

  def to_ruby(scope, operators)
    Sorcerer.source self.to_sexp(scope, operators)
  end  

  def build(operators, scope)
    to_sexp(scope)
  end

  def to_sexp(scope, operators)
    first_variable = 'var'+@indexes[0].to_s
    [:program,
     [:stmts_add,
      [:stmts_new],
      [:method_add_arg,
       [:call,
        [:vcall, [:@ident, first_variable ]],
        :".",
        [:@ident, "concat"]],
       [:arg_paren,
        [:args_add_block,
         [:args_add,
          [:args_new],
          [:string_literal,
           [:string_add, [:string_content], [:@tstring_content, @constant]]]],
         false]]]]]
  end

end