class ConcatOperator

  def initialize(constant)
    @constant = constant
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

  def to_ruby
    #'  var0.concat(\''+@constant.to_s+'\')'+"\n"
    Sorcerer.source self.to_sexp('var0')
  end

  def build(subject, variables = [])
    to_sexp(subject)
  end

  def to_sexp(subject)
    #[s(:call, s(:call, nil, subject.to_sym, s(:arglist)), :concat, s(:arglist, s(:str, string))]
    #sexp = Ripper::SexpBuilder.new("  var0.concat('bar')").parse
    [:program, 
      [:stmts_add, 
        [:stmts_new], 
        [:method_add_arg, 
          [:call, 
            [:vcall, [:@ident, subject, [1, 2]]], 
            :".", [:@ident, "concat", [1, 7]]
          ], 
          [:arg_paren, [:args_add_block, [:args_add, [:args_new], [:string_literal, [:string_add, [:string_content], [:@tstring_content, @constant, [1, 15]]]]], false]]]
      ]
    ]
  end

end