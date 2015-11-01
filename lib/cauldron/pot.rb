module Cauldron

  class Pot

    def solve(problems)

      # Identify the relationship
      
      # Pry::Code
      # TODO Change term to solution
      relationship = find_relationship(problems)

      # Generate if statements
      result = ''

      # Add the arguments
      # [:program, 
      #   [:stmts_add, 
      #     [:stmts_new], 
      #     [:def, 
      #       [:@ident, "function", [1, 4]], 
      #       [:paren, [:params, [[:@ident, "var0", [1, 13]]], nil, nil, nil, nil]], 
      #       [:bodystmt, [:stmts_add, [:stmts_new], [:binary, [:var_ref, [:@ident, "var0", [2, 2]]], :*, [:@int, "3", [2, 9]]]], nil, nil, nil]]
      #   ]
      # ]
      args = problems.first[:arguments]
      variables = (0...args.length).collect {|x| 'var'+x.to_s}
      sexp = Ripper::SexpBuilder.new('def function('+variables.join(',')+');'+relationship.to_ruby(variables)+"; end").parse

      Sorcerer.source(sexp, indent: true)

    end

    def chain_operators(problems,operators)
      # TODO Presumes only two operators
      operators[0].to_ruby(operators[1...operators.length], ['var0'])
    end

    def viable_double_operators(problems)
      child_operators = single_viable_operators(problems)

      # Update the arguements operator
      results = []
      child_operators.each do |action|
        next unless action.uses_block?
        updated_problems = []
        problems.each do |problem|
          updated_problems += action.step_problem(problem)
        end
        viable_next_operators = single_viable_operators(updated_problems) 
        results += [action].product(viable_next_operators)
      end
      results
    end   

    def single_viable_operators(problems)

      operations = [ 
        NumericOperator, ArrayReverseOperator, 
        HashKeyValueOperator, StringAsteriskOperator, ArrayCollect,
        ConcatOperator
      ]

      # Try each possible operation
      viable_option_classes = []
      operations.each do |operation_class|

        # Are all the problems viable for this operation
        if problems.all? {|x| operation_class.viable?(x[:arguments],x[:response]) }
          viable_option_classes << operation_class
        end

      end

      viable_option_classes

    end 

    def build_chain_operator(operators, problems)
      
      first_operator_class, second_operator_class = operators[0], operators[1]

      first_operators = build_operators( first_operator_class, problems )

      first_operator = first_operators.first 
      
      values = problems.first[:arguments][0]
      first_operator_history = first_operator.context_history(['var0'], values)

      second_operators =  second_operator_class.instances(
                            first_operator_history,
                            problems.first[:response]
                          )

      

      #second_operators = build_operators( second_operator_class, problems )

      return nil if first_operators.empty? || second_operators.empty?

      variations = first_operators.product(second_operators) 

      Cauldron::Solution::Composite.new( variations.first)
    end        

  protected

    def quote(value)
      if value.kind_of?(String)
        return "'#{value}'"
      end
      value.to_s
    end

    def build_operators(operation_class,problems)
      results = []
      if operation_class.uses_constants?
        
        possible_constants = operation_class.find_constants(problems)

        possible_constants.each do |constant|
          operator = operation_class.new([0],constant)
          results << operator
        end
      else

        # Does the operator always result in the correct solution
        operator = operation_class.new([0])
        results << operator                 

      end
      results
    end

    def find_relationship(problems)     

      # ==== NEW APPROACH ====

      # BRUTE FORCE - Loop through all the solutions
      solutions = [
        Cauldron::Solution::One.new
      ]
      successful_solutions = solutions.select do |solution|
        problems.all? { |problem| solution.successful?(problem) }
      end
      return successful_solutions[0] unless successful_solutions.empty?

      solutions = []
      single_viable_operators(problems).each do |operation_class|

        operators = build_operators(operation_class,problems)
        operators.each do |operator|
          solutions << Cauldron::Solution::Composite.new( [operator] )
        end
      end

      solutions.each do |solution|
        if problems.all? {|x| solution.successful?(x) }
          return solution
        end
      end

      operator_chains = viable_double_operators(problems)

      operator_chains.each do |operators|
        
        code = build_chain_operator(operators,problems)
        if problems.all? {|x| code.successful?(x) }
          return code
        end
      end

      if IfRelationship.match? problems
        return IfRelationship.new(problems)
      end
      IfRelationShip.new(problems)
    end
    
  end
  
end

# Package Gem
# http://www.zenspider.com/projects/hoe.html