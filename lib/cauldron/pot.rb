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

      # problems.each_with_index do |x,i|
      #   result += '  if '+variables[0].to_s+' == '+quote(x[:arguments][0])+"\n"
      #   result += '    return '+quote(x[:response])+"\n"
      #   result += '  end'+"\n"
      # end
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
      #if NumericValueRelationship.match? problems
      #  return NumericValueRelationship.new(problems)
      #end      

      # Are all the problems viable for this operation
      if problems.all? {|x| NumericOperator.viable?(x[:arguments],x[:response]) }
        possible_constants = NumericOperator.find_constants(problems)
        possible_constants.each do |constant|
          numeric_operator = NumericOperator.new(constant)

          # Does the operator always result in the correct solution
          if problems.all? {|x| numeric_operator.successful?(x) }
            return numeric_operator
          end

        end
      end

      # possible_constants = NumericOperator.find_constants(problems)
      # possible_constants.each do |constant|
      #   numeric_operator = NumericOperator.new(constant)

      #   # viability needs to come before the operator is created

      #   # Are all the problems viable for this operation
      #   if problems.all? {|x| numeric_operator.viable?(x[:arguments],x[:response]) }
      #     binding.pry
      #   end

      # end

      if IfRelationship.match? problems
        return IfRelationship.new(problems)
      end
      IfRelationShip.new(problems)
    end
    
  end
  
end

# Package Gem
# http://www.zenspider.com/projects/hoe.html