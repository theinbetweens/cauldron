class NumericOperator

  # Maybe NumericOperation

  def initialize(indexes, constant)
    @constant, @indexes = constant, indexes
  end

  def self.init(indexes, constant)
    self.new(indexes, constant)
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

  def realizable?(histories)
    parameters = histories.variable_permutations(@indexes.length)
    parameters.each do |params|
      begin
        realize(params)
      rescue TypeError
        return false
      end
      #   failed_uses << { composite:composite, examples: examples}
      #   return false        
      # end
    end
    true
  end

  def realize(params)
    o = Object.new
    a = %Q{
      def function(var0)
        #{Sorcerer.source(to_sexp(Cauldron::Scope.new(['var0'])), indent: true)}
      end
    }
    o.instance_eval(a)
    o.function(*params.values)
  end

  def to_sexp(scope)
    [:binary, [:@ident, scope[@indexes[0]] ] , :+, [:@int, @constant.to_s]]
  end

  def to_ruby(scope)
    Sorcerer.source self.to_sexp(scope)
  end

  def build(operators, scope)
    to_sexp(scope)    
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
    problems.collect {|x| x.response - x.arguments.first }.uniq
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

  def self.instances(histories, composite, examples, insert_points)
    constant = examples.examples.first.response - histories.first.logs.first[:var0] 
    [
      Cauldron::Solution::Composite.new(
      [ Tree::TreeNode.new("CHILD1", self.new([0],constant) ) ]
      )
    ]
  end
    
end