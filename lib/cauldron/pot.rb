module Cauldron

  class Pot

    def solve(problems)

      # Identify the relationship
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

  protected

    def quote(value)
      if value.kind_of?(String)
        return "'#{value}'"
      end
      value.to_s
    end

    def find_relationship(problems)     

      operations = [ 
        NumericOperator, ConcatOperator, ArrayReverseOperator, 
        HashKeyValueOperator, StringAsteriskOperator
      ]

      # Try each possible operation
      operations.each do |operation_class|

        # Are all the problems viable for this operation
        if problems.all? {|x| operation_class.viable?(x[:arguments],x[:response]) }

          if operation_class.uses_constants?

            possible_constants = operation_class.find_constants(problems)
            possible_constants.each do |constant|
              operator = operation_class.new(constant)

              # Does the operator always result in the correct solution
              if problems.all? {|x| operator.successful?(x) }
                return operator
              end
            end

          else

            # Does the operator always result in the correct solution
            operator = operation_class.new
            if problems.all? {|x| operator.successful?(x) }
              return operator
            end            

          end

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