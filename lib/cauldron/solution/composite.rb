module Cauldron::Solution

  class Composite

    attr_reader :operators

    def initialize(*operators)
      @operators = operators
    end

    def sexp
      # [ 
      #   :1, [],
      #   :2, [],
      # ]

      #operators.shift.build(operators)
      #puts operators.inspect
      #puts '===='
      results = operators.collect do |x|
        #line = x.shift
        #options = x
        x[0].build(x[1...x.length])
      end
      # TODO Not sure why this is needed just yet
      results.shift
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
      a = [
        'def function('+variables.join(',')+');'+self.to_ruby+"; end", 
        'function('+problem[:arguments].collect {|x| to_programme(x) }.join(',')+')'
      ]
      
      res = pt.eval(
        ['def function('+variables.join(',')+');'+self.to_ruby+"; end", 'function('+problem[:arguments].collect {|x| to_programme(x) }.join(',')+')']
      )

      #problem[:response] == Pry::Code.new(self.to_ruby)
      problem[:response] == res
      #''


      #false
    end

    def to_programme(value)
      if value.kind_of?(String)
        return %Q{'#{value}'}
      end
      value.to_s
    end

    # TODO Add a safety evalutor
    
  end

end