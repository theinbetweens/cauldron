class ConcatOperator

  def initialize(indexes, constant)
    @indexes, @constant = indexes, constant
  end

  def self.viable?(arguments, response)
    return false unless arguments.all? { |x| x.kind_of?(String) }
    return false unless response.kind_of?(String)
    # TODO - Only accpets one argument
    true
  end

  def self.find_constants(problems)
    problems.inject([]) do |total, x| 
      result = x[:response].gsub( Regexp.new('^'+x[:arguments].first),'')
      total << result unless result == x[:response]
      total
    end.uniq
  end

  def self.uses_constants?
    true
  end  

  # Operator for "x.concat("bar")"
  def successful?(problem)
    if (problem[:arguments].first + @constant) == problem[:response]
      return true
    end
    return false
  end

  def to_ruby(variables)
    Sorcerer.source self.to_sexp(variables)
  end

  def build(operators, scope)
    to_sexp(scope)
  end

  def to_sexp(scope)
    [:program,
     [:stmts_add,
      [:stmts_new],
      [:method_add_arg,
       [:call,
        [:vcall, [:@ident, scope[@indexes[0]] ]],
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