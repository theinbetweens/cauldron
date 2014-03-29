class NumericOperator

  # Maybe NumericOperation

  def initialize(constant)
    @constant = constant
  end

  # Is the problem suitable for a numeric operatio?
  # e.g. can the .find_contants call be called without error
  def self.viable?(arguments,output)

    # 1. Only has one argument value
    # 2. Argument is a numeric value
    # 3. Response is numeric

    # TODO  Need to save these viablility tests in shared (easily comparable) state.
    #       e.g. so all viable operations can be found in one go. 

    return false unless arguments.all? { |x| x.kind_of?(Numeric) }
    return false unless output.kind_of?(Numeric)
    true

  end

  def to_ruby
    '  var0 + '+@constant.to_s+"\n"
  end

  # Operator for "x + n" e.g. x + 1
  def successful?(problem)
    # Does the input match the answer
    #problem.collect {|x| x[:response] - x[:arguments].first }.uniq.length == 1
    if (problem[:arguments].first + @constant) == problem[:response]
      return true
    end
    return false
  end

  def self.find_constants(problems)
    problems.collect {|x| x[:response] - x[:arguments].first }.uniq
  end

  def self.uses_constants?
    true
  end  

end