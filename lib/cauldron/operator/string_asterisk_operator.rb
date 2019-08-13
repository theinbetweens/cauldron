# frozen_string_literal: true

class StringAsteriskOperator
  # var0 * 3

  # TODO: Possibly include the scope of the index
  # a = 5
  # ['sdsd'].each do |b|
  #   c = 5
  # end
  # (1...6).each do |d|
  #   g = d
  # end

  # [0] = ['a']
  # [1] = ['b', 'c']
  # [2] = ['g', 'd']

  # Although it should probably be
  # [0] = [ ['a'] ]
  # [1] = [ ['b', 'c'], ['g', 'd'] ]
  #
  # Or the order it was added might be more useful - e.g. last variable, second last variable or first variable
  # - variable at depth(1)[1] - stepUp(1).first

  def initialize(indexes)
    @indexes = indexes
    @constant = 2
    # @constant, @indexes = constant, indexes
  end

  def self.instances(histories, composite, examples, insert_points)
    # TEMP
    unless examples.class == ExampleSet
      raise StandardError, 'Examples should be an example'
    end

    # Print out each insertable statements
    scope = examples.scope

    # self.init([0]).to_ruby(scope)
    # - this will print out "var0.chop"

    # Get the variables available at each point
    results = []

    insert_points.each do |point|
      # Find the variables at a particular point
      # TODO Change to test
      contexts = histories.contexts_at(point)
      composites = context_instances(contexts)

      composites.each do |x|
        next unless contexts.all? do |context|
          x.context_realizable?(context)
        end

        results << extend_actualized_composite(x, composite, examples, point)
      end
    end

    results
  end

  # def self.instances(context_history, target)
  #   res = history_goals(context_history, target)

  #   possible_constant = res.collect do |x|
  #     x[1].scan( x[0][:x] ).count
  #   end.uniq

  #   if possible_constant.length == 1
  #     #return [StringAsteriskOperator.new([1],possible_constant.first)]
  #     return [StringAsteriskOperator.new([1])]
  #   end

  # end

  def self.history_goals(context_history, target)
    variables = context_history.first.keys
    context_history.each { |x| x[variables.first] }.zip(target)
  end

  def self.find_constants(problems)
    return [] unless problems.all? { |x| x.response.is_a?(String) }

    problems.collect { |x| x.response.scan(x.arguments.first).count }.reject { |x| x == 0 }
  end

  def self.viable?(arguments, output)
    return false unless output.is_a?(String)
    return false unless arguments.first.is_a?(String)

    true
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

  def successful?(problem)
    return true if problem[:arguments].first * @constant == problem[:response]

    false
  end

  def to_ruby(scope, _operators)
    Sorcerer.source to_sexp([], scope)
  end

  # def to_sexp(operators, scope)
  #   [:binary, [:vcall, [:@ident, scope[@indexes[0]] ]], :*, [:@int, @constant]]
  # end
  def to_sexp(_scope, _children)
    first_variable = 'var' + @indexes[0].to_s
    Ripper::SexpBuilder.new(%(#{first_variable} * #{@constant})).parse
  end

  # TODO: Get rid of the defined names
  def build(operators, scope)
    to_sexp(operators, scope)
  end
end
