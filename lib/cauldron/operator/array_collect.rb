class ArrayCollect

  def initialize
    
  end

  def to_ruby(operator = nil)
    #sexp = Ripper::SexpBuilder.new(%q{var0.collect { |x| x * 2 }}).parse
    block_sexp = [:var_ref, [:@ident, "x"]]
    unless operator.nil?
      block_sexp = operator.to_sexp('x')
    end
    sexp = 
    [:method_add_block, 
      [:call, 
        [:vcall, 
          [:@ident, "var0"]], 
          :".", 
          [:@ident, "collect"]
      ], 
      [:brace_block, 
        [:block_var, 
          [:params, [[:@ident, "x"]]]], 
          [:stmts_add, [:stmts_new], block_sexp
        ]
      ]
    ] 
    Sorcerer.source(sexp)
  end

  def self.viable?(arguments,output)
    return false unless output.kind_of? Array
    return false unless arguments.first.kind_of? Array
    true    
  end

  def self.uses_block?
    true
  end  

  def build(operators)
    [:method_add_block, 
      [:call, 
        [:vcall, 
          [:@ident, "var0"]], 
          :".", 
          [:@ident, "collect"]
      ], 
      [:brace_block, 
        [:block_var, 
          [:params, [[:@ident, "x"]]]], 
          [:stmts_add, [:stmts_new], operators.first.build('x')
        ]
      ]
    ]    
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

    # binding.pry

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