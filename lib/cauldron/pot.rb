module Cauldron

  class Pot

    def solve(problems)

      # Identify the relationship
      
      # Pry::Code
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
      sexp = Ripper::SexpBuilder.new('def function('+variables.join(',')+');'+relationship.to_ruby+"; end").parse

      Sorcerer.source(sexp, indent: true)

    end

    def chain_operators(problems,operators)
      # TODO Presumes only two operators
      operators[0].to_ruby(operators[1])
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
        NumericOperator, ConcatOperator, ArrayReverseOperator, 
        HashKeyValueOperator, StringAsteriskOperator, ArrayCollect
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

    def build_chain_operators(operators, problems)
      
      next_problem = operators.first.step_problem(problems.first)

      res = build_operators(operators.last,next_problem)

      operators.first.new.to_ruby(res.first)
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
          operator = operation_class.new(constant)
          results << operator
        end
      else

        # Does the operator always result in the correct solution
        operator = operation_class.new
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
          solutions << Cauldron::Solution::Composite.new( operator )
          # if problems.all? {|x| operator.successful?(x) }
          #   return operator
          # end
        end
      end
      #solutions.each { |x| x.successful?(problem) }
      solutions.each do |solution|
        if problems.all? {|x| solution.successful?(x) }
          return solution
        end
      end


      operator_chains = viable_double_operators(problems)

      operator_chains.each do |operators|
        
        code = build_chain_operators(operators,problems)
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