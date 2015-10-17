class StringAsteriskOperator

  # var0 * 3

  def initialize(constant)
    @constant = constant
  end

  def self.find_constants(problems)
    problems.collect {|x| x[:response].scan(x[:arguments].first).count }.reject {|x| x == 0}
  end

  def self.viable?(arguments,output)
    return false unless output.kind_of?(String)
    return false unless arguments.first.kind_of?(String)
    true
  end

  def self.uses_constants?
    true
  end

  def self.uses_block?
    false
  end  

  def successful?(problem)
    return true if problem[:arguments].first*@constant == problem[:response]    
    false
  end

  def to_ruby(variable_name = 'var0')
    Sorcerer.source self.to_sexp
  end

  def to_sexp(variable_name = 'var0')
    [:binary, [:vcall, [:@ident, variable_name]], :*, [:@int, @constant]]
  end

  # TODO Get rid of the defined names
  def build(nested, variable_name = 'var0')
    [:binary, [:vcall, [:@ident, variable_name]], :*, [:@int, @constant]]
  end

end