module Cauldron::Solution

  class Composite

    attr_reader :operators

    def initialize(children)
      raise StandardError.new('inital value should be an array') unless children.kind_of?(Array)      
      @operators = children
    end

    def record(example)
      # TODO params passed twice - and example not used at all
      insert_tracking(example.params).process(example)
    end

    def end_points
      results = []
      operators.each do |x|
        if x.content.branch?
          results << [0,x.children.length]
        end
      end
      results << [operators.length]
    end

    def clone_solution
      #self.clone
      tree_operators = operators.collect do |node|
        Tree::TreeNode.new('x', node.content.clone_statement)
      end
      Composite.new(tree_operators)
    end

    def add_statement_at(statement, point)
      if point.length == 2
        container = self.operators[0]
        #return self if container.length > 1 # TODO: Quick hack to get it working
        container << Tree::TreeNode.new('SASA', statement)
      elsif point.length == 1
        operators << Tree::TreeNode.new('SASA', statement)
      else
        raise StandardError.new('Have not written code: '+point.inspect)
      end
      self
    end

    def insert_tracking(params)
      scope = Cauldron::Scope.new(params.clone)

      # TODO Might be useful
      # trace = TracePoint.new(:call) do |tp|
      #   p [tp.lineno, tp.event, tp.raised_exception]
      # end

      
      # NEW: Implementation
      m = %Q{
        def function(#{params.join(',')})
          #{to_ruby(Cauldron::Scope.new(params.clone))}
        end
      }

      sexp = Ripper::SexpBuilder.new(m).parse
      rendered_code = Sorcerer.source(sexp, indent: true)
      caret = Cauldron::Caret.new

      # Generate tracking code with pending substitutions
      tracked_code = []
      rendered_code.each_line do |line|
        if line.match /end\s+/
          tracked_code << Sorcerer.source(Ripper::SexpBuilder.new(Cauldron::Tracer.substitue_tracking).parse) #Sorcerer.source(Cauldron::Tracer.substitue_tracking)
        end
        tracked_code << line
      end
      sexp = Ripper::SexpBuilder.new(tracked_code.join("\n")).parse       
      code_tracking  = Sorcerer.source(sexp, indent: true)
      code_tracking.split("\n")

      current_line = -1
      total_lines = 0
      new_tracked_code = []
      last_line = nil
      relative_line = 0
      placeholder = nil
      point = [0,0]
      current_depth = 0
      caret = Cauldron::Caret.new

      #parent_node = Tree::TreeNode.new("ROOT", "Root Content")
      #binding.pry
      points = end_points

      code_tracking.split("\n").each do |line|

        #next_node = Tree::TreeNode.new("CHILD1", line)
        #depth = (line.match(/^(\s+)/)[0].length / 2) -1
        #parent_node << next_node

        if line.match /record/
          depth = (line.match(/^(\s+)/)[0].length / 2) -1
          if depth > current_depth
            relative_line = 0
          end
          current_depth = depth

          new_tracked_code << last_line
          new_tracked_code << Sorcerer.source(
                                Cauldron::Tracer.tracking(relative_line, depth, total_lines, points.shift)
                              )
          new_tracked_code << placeholder
        else
          total_lines += 1
          placeholder = "#{'placeholder_'+rand(10000000000).to_s}"
          last_line = "#{placeholder} = "+line

          if !last_line.match(/\s+end/).nil? || !last_line.match(/function/).nil? # || last_line.match /function/
            last_line = nil
            placeholder = nil
          end

          new_tracked_code << line
          current_line += 1
        end
        #total_lines += 1
      end

      # NOTE: Keep this to debug before conversion of S-EXP
      # puts '&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&'
      # new_tracked_code.each do |x|
      #   puts x
      # end
      
      sexp = Ripper::SexpBuilder.new(new_tracked_code.join("\n")).parse 

      #puts '==========='
      #puts Sorcerer.source(sexp, indent: true)
      #puts '==========='
      
      Cauldron::Tracer.new(sexp)

    end

    # def tracking_sexp(scope, caret)
    #   if operators.empty?
    #     sexp = [:bodystmt,
    #       [:stmts_add,
    #         [:stmts_new]
    #       ],
    #       Cauldron::Tracer.tracking(caret.line, caret.current_depth, caret.total_lines)
    #     ]        
    #   else

    #     if operators.length == 1
    #       inner = operators.first.content.to_tracking_sexp(
    #                 operators.first.children, scope, caret
    #               ) 
    #       sibling = reset_and_track(caret)
    #       sexp = [
    #               :bodystmt,
    #                 [:stmts_add, 
    #                   [:stmts_add,
    #                     [:stmts_new],
    #                     inner
    #                   ],
    #                   sibling
    #                 ]
    #               ]
    #     else
    #       raise StandardError.new('Currently only supporting 1')
    #     end
    #   end
    #   sexp
    # end

    def reset_and_track(caret)
      caret.return_depth(0)
      Cauldron::Tracer.tracking(caret.line, caret.current_depth, caret.total_lines)
    end

    def to_sexp(variables=[])

      #binding.pry
      operators.each do |operator|
        #binding.pry
        #operator.content
        operator.content.to_ruby(variables)
      end


      first = operators.first
      
      #inner = add_first_statement( first.content.build(first.children.first, variables) )

      inner = add_first_statement( 
                first.content.build(
                  first.children, variables
                ) 
              )

      second = operators[1]
      
      if second.nil?
        results = inner
      else
        results = add_statement(
                    second.content.build(second.children, variables),
                    inner
                  )
      end
      
      # TODO Not sure why this is needed just yet
      [:program, results]
    end

    def to_ruby(scope)
      return '' if operators.empty?
      Sorcerer.source(to_sexp(scope))
    end

    def add_first_statement(statement)
      [:stmts_add, [:stmts_new], statement]
    end

    def add_statement(statement, inner)
      [:stmts_add, inner, statement]
    end

    def solution?(problems)
      o = Object.new
      m = %Q{
        def function(#{problems.variables.join(',')})
          #{to_ruby(problems.scope)}
        end
      }
      o.instance_eval(m)

      #o.function *problems.examples.first.arguments
      problems.all? do |example|
        o.function(*example.arguments) == example.response
      end

    end

    # TODO Drop this method
    def successful?(problem)

      # # TODO track the parameters of the operator
      # operators.trace(problem)

      # # TODO For now just evalute the code
      # return true if problem[:arguments].first == problem[:response]    
      # false

      pt = PryTester.new

      args = problem.arguments
      variables = problem.params #(0...args.length).collect {|x| 'var'+x.to_s}
      a = [
        'def function('+variables.join(',')+');'+self.to_ruby(variables)+"; end", 
        'function('+problem.arguments.collect {|x| to_programme(x) }.join(',')+')'
      ]
      
      res = pt.eval(
        ['def function('+variables.join(',')+');'+self.to_ruby(variables)+"; end", 'function('+problem.arguments.collect {|x| to_programme(x) }.join(',')+')']
      )

      problem.response == res
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