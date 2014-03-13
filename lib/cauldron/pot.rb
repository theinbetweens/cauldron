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
      if NumericValueRelationship.match? problems
        return NumericValueRelationship.new(problems)
      end      
      if IfRelationship.match? problems
        return IfRelationship.new(problems)
      end
      IfRelationShip.new(problems)
    end
    
  end
  
end