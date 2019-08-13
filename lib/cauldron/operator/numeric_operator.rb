# frozen_string_literal: true

class NumericOperator
  include Cauldron::Operator

  # Maybe NumericOperation
  ADDITION = 4

  def initialize(indexes)
    @indexes = indexes
  end

  # Is the problem suitable for a numeric operatio?
  # e.g. can the .find_contants call be called without error
  def self.viable?(arguments, output)
    # 1. Only has one argument value
    # 2. Argument is a numeric value
    # 3. Response is numeric

    # TODO: Need to save these viablility tests in shared (easily comparable) state.
    #       e.g. so all viable operations can be found in one go.

    return false unless arguments.all? { |x| x.is_a?(Numeric) }
    return false unless output.is_a?(Numeric)

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
    end
    true
  end

  def realize(params)
    o = Object.new
    a = %{
      def function(var0)
        #{Sorcerer.source(to_sexp(Cauldron::Scope.new(['var0']), []), indent: true)}
      end
    }
    o.instance_eval(a)
    o.function(*params.values)
  end

  def to_sexp(scope, _operators)
    [:binary, [:@ident, scope[@indexes[0]]], :+, [:@int, ADDITION.to_s]]
  end

  def to_ruby(scope, operators)
    Sorcerer.source to_sexp(scope, operators)
  end

  def build(_operators, scope)
    to_sexp(scope)
  end

  # Operator for "x + n" e.g. x + 1
  # Does the input match the answer
  def successful?(problem)
    return true if (problem[:arguments].first + ADDITION) == problem[:response]

    false
  end

  def self.find_constants(problems)
    problems.collect { |x| x.response - x.arguments.first }.uniq
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

  def context_realizable?(context)
    vars = context.keys.select { |x| x.match(/var\d/) }
    var_names = vars.collect(&:to_s)

    first_variable = 'var' + @indexes[0].to_s

    a = %{
    def function(#{first_variable})
      #{Sorcerer.source(to_sexp(Cauldron::Scope.new(var_names), []), indent: true)}
    end
    }

    o = Object.new
    o.instance_eval(a)

    begin
      # o.function(*vars.collect {|x| context[x] })
      o.function context[first_variable.to_sym]
    rescue NoMethodError => e
      return false
    rescue StandardError => e
      puts e
    end
    true
  end
end
