module Cauldron

  class Pot

    def solve(problems)

      example_set = Cauldron::ExampleSet.new(problems.collect {|x| Cauldron::Example.new(x) })

      # Identify the relationship
      
      # Pry::Code
      # TODO Change term to solution
      relationship = find_relationship(example_set)

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
      #args = problems.first[:arguments]
      #variables = (0...args.length).collect {|x| 'var'+x.to_s}
      variables = example_set.variables
      sexp = Ripper::SexpBuilder.new('def function('+variables.join(',')+');'+relationship.to_ruby(variables)+"; end").parse

      Sorcerer.source(sexp, indent: true)

    end

    def chain_operators(problems,operators)
      # TODO Presumes only two operators

      operators[0].to_ruby( [
        Tree::TreeNode.new("CHILD1", operators[1])
      ], Cauldron::Scope.new(['var0']) )
    end

    def viable_double_operators(problems)
      child_operators = single_viable_operators(problems)

      # Update the arguements operator
      results = []
      child_operators.each do |action|
        next unless action.uses_block?
        updated_problems = []
        problems.examples.each do |problem|
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
        if problems.all? {|x| operation_class.viable?(x.arguments,x.response) }
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

      return nil if first_operators.empty? || second_operators.empty?

      variations = first_operators.product(second_operators) 

      variation = variations.first
      
      root = Tree::TreeNode.new("ROOT", "Root Content")
      child = Tree::TreeNode.new("CHILD1", variation[0]) 
      grand_child = Tree::TreeNode.new("CHILD2", variation[1])
      child << grand_child
      root << child
      root

      Cauldron::Solution::Composite.new( root.children )
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

      # # Create the empty
      # current_code = Cauldron::ActualizedComposite.new(
      #   Cauldron::Composite.new([], problems)
      # )
      # histories = current_code.process
      # new_composites = Cauldron::Composite.new([], problems).build_extensions(histories)
      # if new_composites.any? {|x| x.solution?(problems) }
      #   return new_composites.select {|x| x.solution?(problems) }
      # end    

      # # Extend the composites
      # new_new_composites = []
      # new_composites.each do |x|
      #   new_new_composites += x.extend_solution(examples)
      # end
      # if new_new_composites.any? {|x| x.solution?(problems) }
      #   return new_new_composites.select {|x| x.solution?(problems) }
      # end      

      #operators.each do |new_operator|
        #composite.build 
      #end
      new_composites =  [ 
                          Cauldron::ActualizedComposite.new(
                            Cauldron::Solution::Composite.new([]), 
                            problems
                          )
                        ]
      itterations = 0
      until itterations == 3
        new_composites = extended_composites(new_composites)
        if new_composites.any? {|x| x.solution?(problems) }
          return new_composites.select {|x| x.solution?(problems) }
        end
        itterations += 1
      end      


      solutions = []
      single_viable_operators(problems).each do |operation_class|

        operators = build_operators(operation_class,problems)
        operators.each do |operator|
          root = Tree::TreeNode.new("ROOT", "Root Content")
          root << Tree::TreeNode.new("CHILD1", operator)
          solutions << Cauldron::Solution::Composite.new(root.children)
        end
      end

      solutions.each do |solution|
        if problems.all? {|x| solution.successful?(x) }
          return solution
        end
      end

      # operator_chains = viable_double_operators(problems)

      # operator_chains.each do |operators|
        
      #   code = build_chain_operator(operators,problems)
      #   if problems.all? {|x| code.successful?(x) }
      #     return code
      #   end
      # end

      if IfRelationship.match? problems
        return IfRelationship.new(problems)
      end
      IfRelationShip.new(problems)
    end

    def extended_composites(composites)
      composites.inject([]) do |total, x|
        total += x.extend_solution; total
      end
    end    
    
  end
  
end

# Package Gem
# http://www.zenspider.com/projects/hoe.html