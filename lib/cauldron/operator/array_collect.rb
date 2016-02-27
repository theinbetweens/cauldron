class ArrayCollect

  attr_reader :indexes

  def initialize(indexes)
    @indexes = indexes
    # TODO Should use a different method to better mirror the DynamicOperator - instances
  end

  # NOTE #history is used by Pry
  def context_history(variable_names,values)
    values.collect {|x| {x: x} }
    # to_ruby([],variable_names)
    # TODO Change to something like this
    # sexp = Ripper::SexpBuilder.new(%q{
    #   var0.collect do |x|
    #     record(local_variable)
    #   end
    # }).parse  
  end

  def to_ruby(scope, operators)
    Sorcerer.source self.to_sexp(scope, operators)
  end

  def self.viable?(arguments,output)
    return false unless output.kind_of? Array
    return false unless arguments.first.kind_of? Array
    true    
  end

  def self.uses_block?
    true
  end

  def branch?
    true
  end

  def ==(value)
    return false unless self.class == value.class
    self.indexes == value.indexes
  end

  def build(children, scope)
    scope_var = scope.new_variable!
    [:method_add_block, 
      [:call, 
        [:vcall, 
          [:@ident, scope[@indexes[0]] ]], 
          :".", 
          [:@ident, "collect"]
      ], 
      unless children.empty?
        [:brace_block, 
          [:block_var, 
            [:params, [[:@ident, scope_var]]]], 
            [
              :stmts_add, 
              [:stmts_new], 
              children.first.content.build(scope_var, scope )
            ]
        ]
      else
        [:brace_block, 
          [:block_var, 
            [:params, [[:@ident, scope_var]]], 
            [:stmts_add, [:stmts_new]]
          ]
        ]        
      end
    ]    
  end

  def to_sexp(scope, operators)
    build(operators, scope)   
  end

  def block_var(variables)
    [:block_var,
      [
        :params, 
        [[:@ident, variables.first]]
      ]
    ]
  end

   # [:method_add_block,
   #  [:call,
   #   [:vcall, [:@ident, "var0", [2, 0]]],
   #   :".",
   #   [:@ident, "collect", [2, 5]]],
   #  [:do_block,
   #   [:block_var,
   #    [:params, [[:@ident, "var1", [2, 17]]], nil, nil, nil, nil, nil, nil],
   #    false],
   #   [:stmts_add,
   #    [:stmts_new],
   #    [:method_add_arg,
   #     [:fcall, [:@ident, "record", [3, 2]]],
   #     [:arg_paren,
   #      [:args_add_block,
   #       [:args_add, [:args_new], [:@int, "0", [3, 9]]],
   #       false]]]]]]

  # def to_tracking_sexp(operators, scope, caret)
  #   caret.add_line(0)
  #   caret.step_in
  #   scope_var = scope.new_variable!
  #   [
  #     :method_add_block,
  #     [
  #       :call,
  #       [:vcall, [:@ident, scope[@indexes[0] ]]],
  #       :".",
  #       [:@ident, "collect"]
  #     ],
  #     [
  #       :do_block,
  #       block_var([scope_var]),
  #       sexp_inserts(
  #         scope, operators, caret
  #         #operators += [Cauldron::Tracer.tracking(line, depth, total_line)]
  #       )
  #     ]
  #   ]
  # end

  def sexp_inserts(scope, children, caret)
    if children.length == 1
      caret.add_line(1)
      #[:stmts_add, [:stmts_add, [:stmts_new], yield 1 ], yield 2 ]
      #[:stmts_add, [:stmts_new], children[0].content.to_sexp(children[0].children, scope) ]
      #elsif children.length == 2
      return [
        :stmts_add, 
        [:stmts_add, 
          [:stmts_new], 
          children[0].content.to_sexp(children[0].children, scope)
        ], 
        Cauldron::Tracer.tracking(caret.line, caret.current_depth, caret.total_lines)
      ]
    end

    if children.length == 0
      return Cauldron::Tracer.tracking(caret.line, caret.current_depth, caret.total_lines)
    end
      
  end

  # Could be blockify_problem
  def self.step_problem(problem)
    result = []
    problem.arguments.flatten.zip( problem.response) do |argument, response|
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

  def self.instances(histories, composite, examples, insert_points)
    results = []
    histories.each do |history|
      results += instances_for_history(history)
    end
    indexes = results.collect {|x| x.to_s.match(/(\d)/)[0] }
    
    indexes.collect do |x|
      Cauldron::ActualizedComposite.new(
        Cauldron::Solution::Composite.new(
          [ Tree::TreeNode.new("CHILD1", ArrayCollect.new([x.to_i]) )  ]
        ),
        examples
      )
    end
  end

  def self.instances_for_history(h)
    h.variables.select do |x| 
      h.values(x).all? {|y| y.kind_of?(Array) }
    end
  end

end