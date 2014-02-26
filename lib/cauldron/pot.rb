module Cauldron

  class Pot
    
    def generate(cases)
      if theories.empty?
        return "There aren't any theories loaded so Cauldron is unable to generate a solution"
      end

      # Generate a resulting function using the available theories
      empty_function = Function.new
      # TODO I need a proper $STDOUT check so I don't need this puts
      output = empty_function.apply_theory(theories.first,cases.first).write
      puts output
      output
    end

    def solve(problems)

      # Generate if statements
      result = ''

      # Add the arguments
      args = problems.first[:arguments]
      variables = (0...args.length).collect {|x| 'var'+x.to_s}
      result = 'def function('+variables.join(',')+')'+"\n"

      problems.each_with_index do |x,i|
        #binding.pry
        result += '  if '+variables[0].to_s+' == '+quote(x[:arguments][0])+"\n"
        result += '    return '+quote(x[:response])+"\n"
        result += '  end'+"\n"
      end
      result += 'end'

      result

    end
    
    def load_theory(filepath)
      theory = TheoryParser.new.parse(filepath)
      theories << theory
      return true
    end

  protected    
    
    def theories
      @theories ||= []
    end

    def quote(value)
      if value.kind_of?(String)
        return "'#{value}'"
      end
      value.to_s
    end
    
  end
  
end