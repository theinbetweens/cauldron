module Cauldron::Solution

  class Composite

    attr_reader :operators

    def initialize(*operators)
      @operators = operators
    end

    def sexp
      operators.shift.build(operators)
    end

    def to_ruby
      Sorcerer.source(sexp)
    end

    def successful?(problem)

      # # TODO track the parameters of the operator
      # operators.trace(problem)

      # # TODO For now just evalute the code
      # return true if problem[:arguments].first == problem[:response]    
      # false    
      pt = PryTester.new
      #pt.eval([self.to_ruby])

      args = problem[:arguments]
      variables = (0...args.length).collect {|x| 'var'+x.to_s}

      result = [
        'def function('+variables.join(',')+')',
        self.to_ruby,
        'end'
      ]

      

      #pt.eval(result)
      #pt.eval(['def function('+variables.join(',')+');'+self.to_ruby+"; end"])

      # 'def function('+variables.join(',')+');'+self.to_ruby+"; end", 'function('+problem[:arguments][0].to_s+')'
      # "def function('+variables.join(',')+');'+self.to_ruby+"; end", 'function('+problem[:arguments][0].to_s+')'
      a = 'def function('+variables.join(',')+');'+self.to_ruby+"; end", 'function('+problem[:arguments][0].to_s+')'

      pt.eval(
        ['def function('+variables.join(',')+');'+self.to_ruby+"; end", 'function('+problem[:arguments].collect(&:to_s).join(',')+')']
      )

      problem[:response] == Pry::Code.new(self.to_ruby)
      #''


      #false
    end

    # TODO Add a safety evalutor
    
  end

end