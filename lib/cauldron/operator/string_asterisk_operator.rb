class StringAsteriskOperator

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

  def successful?(problem)
    return true if problem[:arguments].first*@constant == problem[:response]    
    false
  end

  def to_ruby(variable_name = 'var0')
    #Sorcerer.source [:binary, [:vcall, [:@ident, "a"]], :*, [:@int, "3"]]
    Sorcerer.source [:binary, [:vcall, [:@ident, variable_name]], :*, [:@int, @constant]]
    "  #{variable_name} * "+"#{@constant}"+"\n"
  end

end