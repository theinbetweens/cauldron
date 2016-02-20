class ArrayReverseOperator

  def initialize(indexes)
    raise StandardError.new('Need at least one item') if indexes.empty?
    @indexes = indexes
  end  

  # Matching in 
  def successful?(problem)
    # NOTE - for the future - like the idea of not actually calling the method
    # input.length.each do |i|
    # does input[0] == output[input.length-0]
    # does input[1] == output[input.length-1]
    # does input[3] == output[input.length-3]
    # end
    
    # in this case x.reverse will work
    return true if problem[:arguments].first.reverse == problem[:response]
    false
  end

  # 1. Only has one argument value
  # 2. Argument is an array value
  # 3. Response is an array 
  def self.viable?(arguments,output)
    return false unless arguments.length == 1
    return false unless arguments.all? { |x| x.kind_of?(Array) }
    return false unless output.kind_of?(Array)
    true
  end

  def self.uses_constants?
    false
  end

  def self.find_constants(problems)
    []
  end

  def self.uses_block?
    false
  end

  def self.process(arguments)
    arguments.collect {|x| x.reverse }
  end

  def to_ruby(operators, scope)
    Sorcerer.source build(operators, scope)
  end

  def build(operators, scope)
    to_sexp(operators, scope)
  end

  def to_sexp(operators, scope)
    [:call, 
      [:vcall, 
        [:@ident, scope[@indexes[0]] ]
      ], 
      :".", 
      [:@ident, "reverse"]
    ]    
  end

end