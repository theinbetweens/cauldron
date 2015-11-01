class ArrayCollect

  def initialize(indexes)
    @indexes = indexes
  end

  def history(variable_names,values)
    to_ruby([],variable_names)
    #binding.pry
    #to_ruby
  end

  def to_ruby(operators, variables)
    Sorcerer.source build(operators, variables)
  end

  def self.viable?(arguments,output)
    return false unless output.kind_of? Array
    return false unless arguments.first.kind_of? Array
    true    
  end

  def self.uses_block?
    true
  end  

  def build(operators, variables = [])
    [:method_add_block, 
      [:call, 
        [:vcall, 
          [:@ident, variables[@indexes[0]] ]], 
          :".", 
          [:@ident, "collect"]
      ], 
      unless operators.empty?
        [:brace_block, 
          [:block_var, 
            [:params, [[:@ident, "x"]]]], 
            [:stmts_add, [:stmts_new], operators.first.build('x', variables.push('x') )
          ]
        ]
      else
        [:brace_block, 
          [:block_var, 
            [:params, [[:@ident, "x"]]], 
            [:stmts_add, [:stmts_new]]
          ]
        ]        
      end
    ]    
  end

  def to_sexp(operators, variables)
    build(operators, variables)   
  end

  # Could be blockify_problem
  def self.step_problem(problem)
    result = []
    problem[:arguments].flatten.zip( problem[:response]) do |argument, response|
      result << { arguments: [argument], response: response }
    end
    result
  end

  def self.uses_constants?
    false
  end

  def successful?(problem)
    return true if problem[:arguments].first == problem[:response]    
    false    
  end

  def trace(problem)

    #CodeRay.scan("[1]", :ruby).term
    # PryTester.new(*args).tap do |t|
    #   (class << t; self; end).class_eval(&block) if block
    # end    
    #
    # pt = PryTester.new
    # pt.eval([self.to_ruby])

    # pt = PryTester.new
    # #pt.eval([self.to_ruby])

    # args = problem[:arguments]
    # variables = (0...args.length).collect {|x| 'var'+x.to_s}

    # result = [
    #   'def function('+variables.join(',')+')',
    #   self.to_ruby,
    #   'end'
    # ]

    # #pt.eval(result)
    # #pt.eval(['def function('+variables.join(',')+');'+self.to_ruby+"; end"])

    # # 'def function('+variables.join(',')+');'+self.to_ruby+"; end", 'function('+problem[:arguments][0].to_s+')'
    # # "def function('+variables.join(',')+');'+self.to_ruby+"; end", 'function('+problem[:arguments][0].to_s+')'
    # a = 'def function('+variables.join(',')+');'+self.to_ruby+"; end", 'function('+problem[:arguments][0].to_s+')'

    # pt.eval(
    #   ['def function('+variables.join(',')+');'+self.to_ruby+"; end", 'function('+problem[:arguments].collect(&:to_s).join(',')+')']
    # )

    # Pry::Code.new(self.to_ruby)
    # ''
    []
  end

end