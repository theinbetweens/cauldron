# frozen_string_literal: true

module Cauldron
  class Pot
    def solve(problems)
      example_set = Cauldron::ExampleSet.new(problems.collect { |x| Cauldron::Example.new(x) })

      # Identify the relationship

      # Pry::Code
      # TODO Change term to solution
      if find_saved_solution(example_set)
        variables = example_set.variables
        solution = find_saved_solution(example_set)
        sexp = Ripper::SexpBuilder.new('def function(' + variables.join(',') + ');' + solution.to_ruby(variables) + '; end').parse
        return Sorcerer.source(sexp, indent: true)
      end
      relationship = find_relationship(example_set)

      # Generate if statements
      result = ''

      variables = example_set.variables
      # sexp = Ripper::SexpBuilder.new('def function('+variables.join(',')+');'+relationship.to_ruby(variables)+"; end").parse
      sexp = Ripper::SexpBuilder.new('def function(' + variables.join(',') + ');' + relationship.to_ruby(example_set.scope) + '; end').parse

      Sorcerer.source(sexp, indent: true)
    end

    def chain_operators(_problems, operators)
      # TODO: Presumes only two operators

      operators[0].to_ruby([
                             Tree::TreeNode.new('CHILD1', operators[1])
                           ], Cauldron::Scope.new(['var0']))
    end

    def single_viable_operators(problems)
      operations = [
        NumericOperator, ArrayReverseOperator,
        HashKeyValueOperator, StringAsteriskOperator,
        ConcatOperator
      ]

      # Try each possible operation
      viable_option_classes = []
      operations.each do |operation_class|
        # Are all the problems viable for this operation
        if problems.all? { |x| operation_class.viable?(x.arguments, x.response) }
          viable_option_classes << operation_class
        end
      end

      viable_option_classes
    end

    protected

    def quote(value)
      return "'#{value}'" if value.is_a?(String)

      value.to_s
    end

    def build_operators(operation_class, problems)
      results = []
      if operation_class.uses_constants?

        possible_constants = operation_class.find_constants(problems)

        possible_constants.each do |_constant|
          # operator = operation_class.new([0],constant)
          operator = operation_class.new([0])
          results << operator
        end
      else

        # Does the operator always result in the correct solution
        operator = operation_class.new([0])
        results << operator

      end
      results
    end

    # BRUTE FORCE - Loop through all the solutions
    def find_saved_solution(examples)
      solutions = [
        Cauldron::Solution::One.new
      ]
      successful_solutions = solutions.select do |solution|
        examples.all? { |problem| solution.successful?(problem) }
      end
      return successful_solutions[0] unless successful_solutions.empty?

      nil
    end

    def find_relationship(examples)
      # ==== NEW APPROACH ====

      new_composites = [
        Cauldron::ActualizedComposite.new(
          Cauldron::Solution::Composite.new([]),
          examples
        )
      ]
      itterations = 0
      until itterations == 2

        new_composites = extended_composites(new_composites)

        if new_composites.any? { |x| x.solution?(examples) }
          return new_composites.select { |x| x.solution?(examples) }.first.composite
        end

        itterations += 1
      end

      # 1. TRY TO FIND SOLUTION via the history
      # 2. Desired history
      # 3. Chaing matching history

      # ================== END HERE ===============

      solutions = []
      single_viable_operators(examples).each do |operation_class|
        operators = build_operators(operation_class, examples)
        operators.each do |operator|
          root = Tree::TreeNode.new('ROOT', 'Root Content')
          root << Tree::TreeNode.new('CHILD1', operator)
          solutions << Cauldron::Solution::Composite.new(root.children)
        end
      end

      solutions.each do |solution|
        return solution if solution.solution?(examples)
      end

      # operator_chains = viable_double_operators(problems)

      # operator_chains.each do |operators|

      #   code = build_chain_operator(operators,problems)
      #   if problems.all? {|x| code.successful?(x) }
      #     return code
      #   end
      # end

      return IfRelationship.new(examples) if IfRelationship.match? examples

      IfRelationShip.new(examples)
    end

    def extended_composites(actualized_composites)
      actualized_composites.inject([]) do |total, x|
        total += x.extend_solution; total
      end
    end
  end
end

# Package Gem
# http://www.zenspider.com/projects/hoe.html
