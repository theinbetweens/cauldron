module Cauldron

  class Pot

    def solve(problems)

      # Identify the relationship
      relationship = find_relationship(problems)

      # Generate if statements
      result = ''

      # Add the arguments
      args = problems.first[:arguments]
      variables = (0...args.length).collect {|x| 'var'+x.to_s}
      result = 'def function('+variables.join(',')+')'+"\n"
      result << relationship.to_ruby
      result += 'end'

      result

    end

  protected

    def quote(value)
      if value.kind_of?(String)
        return "'#{value}'"
      end
      value.to_s
    end

    def find_relationship(problems)     

      operations = [NumericOperator, ConcatOperator, ArrayReverseOperator]

      # Try each possible operation
      operations.each do |operation_class|

        # Are all the problems viable for this operation
        if problems.all? {|x| operation_class.viable?(x[:arguments],x[:response]) }
          possible_constants = operation_class.find_constants(problems)
          possible_constants.each do |constant|
            operator = operation_class.new(constant)

            # Does the operator always result in the correct solution
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