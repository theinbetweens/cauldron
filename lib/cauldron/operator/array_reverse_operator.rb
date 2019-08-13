# frozen_string_literal: true

class ArrayReverseOperator
  def initialize(indexes)
    raise StandardError, 'Need at least one item' if indexes.empty?

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
  def self.viable?(arguments, output)
    return false unless arguments.length == 1
    return false unless arguments.all? { |x| x.is_a?(Array) }
    return false unless output.is_a?(Array)

    true
  end

  def self.uses_constants?
    false
  end

  def self.find_constants(_problems)
    []
  end

  def self.uses_block?
    false
  end

  def self.process(arguments)
    arguments.collect(&:reverse)
  end

  def to_ruby(operators, scope)
    Sorcerer.source build(operators, scope)
  end

  def build(operators, scope)
    to_sexp(operators, scope)
  end

  def to_sexp(scope, _operators)
    [:call,
     [:vcall,
      [:@ident, scope[@indexes[0]]]],
     :".",
     [:@ident, 'reverse']]
  end

  def branch?
    false
  end

  def self.init(indexes)
    new(indexes)
  end

  def self.instances(histories, composite, examples, insert_points)
    # TEMP
    unless examples.class == Cauldron::ExampleSet
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

      # scopes = scopes_at_point(point)

      composites.each do |x|
        next unless contexts.all? do |context|
                      x.context_realizable?(context)
                    end

        results << extend_actualized_composite(x, composite, examples, point)
      end
    end

    results
  end

  def self.extend_actualized_composite(x, container, examples, point)
    cloned_container = container.clone_solution
    cloned_container.add_statement_at(x, point)
    cloned_container
    Cauldron::ActualizedComposite.new(cloned_container, examples)
  end

  def clone_statement
    self.class.init(@indexes.clone)
  end

  def context_realizable?(context)
    vars = context.keys.select { |x| x.match(/var\d/) }
    var_names = vars.collect(&:to_s)

    a = %{
    def function(var0)
      #{Sorcerer.source(to_sexp(Cauldron::Scope.new(var_names), []), indent: true)}
    end
    }

    o = Object.new
    o.instance_eval(a)

    begin
      o.function(vars.collect { |x| context[x] })
    rescue NoMethodError => e
      return false
    rescue StandardError => e
      puts e
    end
    true
  end

  def self.context_instances(contexts)
    results = []
    contexts.each do |context|
      results << context.keys.collect(&:to_s).select { |x| x.match(/var\d/) }
    end
    results = results.flatten.uniq
    variable_numbers = results.collect { |x| x.match(/var(\d+)/)[1] }
    variable_numbers.collect { |x| init([x.to_i]) }
  end
end
