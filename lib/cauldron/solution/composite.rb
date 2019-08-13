# frozen_string_literal: true

module Cauldron::Solution
  class Composite
    attr_reader :operators

    def initialize(children)
      raise StandardError, 'inital value should be an array' unless children.is_a?(Array)

      @operators = children
    end

    def record(example)
      # TODO: params passed twice - and example not used at all
      insert_tracking(example.params).process(example)
    end

    def end_points
      results = []
      operators.each do |x|
        results << [0, x.children.length] if x.content.branch?
      end
      results << [operators.length]
    end

    def clone_solution
      # self.clone
      tree_operators = operators.collect do |node|
        Tree::TreeNode.new('x', node.content.clone_statement)
      end
      Composite.new(tree_operators)
    end

    def add_statement_at(statement, point)
      if point.length == 2
        container = operators[0]
        # return self if container.length > 1 # TODO: Quick hack to get it working
        container << Tree::TreeNode.new('SASA', statement)
      elsif point.length == 1
        operators << Tree::TreeNode.new('SASA', statement)
      else
        raise StandardError, 'Have not written code: ' + point.inspect
      end
      self
    end

    def insert_tracking(params)
      scope = Cauldron::Scope.new(params.clone)

      # TODO: Might be useful
      # trace = TracePoint.new(:call) do |tp|
      #   p [tp.lineno, tp.event, tp.raised_exception]
      # end

      # NEW: Implementation
      m = %{
        def function(#{params.join(',')})
          #{to_ruby(Cauldron::Scope.new(params.clone))}
        end
      }

      sexp = Ripper::SexpBuilder.new(m).parse
      rendered_code = Sorcerer.source(sexp, indent: true)
      caret = Cauldron::Caret.new

      rendered_code = Sorcerer.source(sexp, indent: true).gsub(/end/, "\nend").split("\n").reject(&:empty?).join("\n")

      # Generate tracking code with pending substitutions
      tracked_code = []
      rendered_code.each_line do |line|
        # if line.match /end\s+/
        if line.match /end/
          tracked_code << Sorcerer.source(Ripper::SexpBuilder.new(Cauldron::Tracer.substitue_tracking).parse) # Sorcerer.source(Cauldron::Tracer.substitue_tracking)
        end
        tracked_code << line
      end
      sexp = Ripper::SexpBuilder.new(tracked_code.join("\n")).parse
      code_tracking = Sorcerer.source(sexp, indent: true)
      code_tracking.split("\n")

      current_line = -1
      total_lines = 0
      new_tracked_code = []
      last_line = nil
      relative_line = 0
      placeholder = nil
      point = [0, 0]
      current_depth = 0
      caret = Cauldron::Caret.new

      points = end_points

      code_tracking.split("\n").each do |line|
        if line.match /record/
          depth = (line.match(/^(\s+)/)[0].length / 2) - 1
          relative_line = 0 if depth > current_depth
          current_depth = depth

          new_tracked_code << last_line
          new_tracked_code << Sorcerer.source(
            Cauldron::Tracer.tracking(relative_line, depth, total_lines, points.shift)
          )
          new_tracked_code << placeholder
        else
          total_lines += 1

          unless line['=']
            placeholder = ('placeholder_' + rand(10_000_000_000).to_s).to_s
            last_line = "#{placeholder} = " + line
          end

          if last_line
            if !last_line.match(/\s+end/).nil? || !last_line.match(/function/).nil? # || last_line.match /function/
              last_line = nil
              placeholder = nil
            end
          end

          if line.match /end$/
            line = line.gsub(/end$/, '') unless line.strip == 'end'
          end

          new_tracked_code << line
          current_line += 1
        end
        # total_lines += 1
      end

      # NOTE: Keep this to debug before conversion of S-EXP
      sexp = Ripper::SexpBuilder.new(new_tracked_code.join("\n")).parse

      Cauldron::Tracer.new(sexp)
    end

    def reset_and_track(caret)
      caret.return_depth(0)
      Cauldron::Tracer.tracking(caret.line, caret.current_depth, caret.total_lines)
    end

    def to_sexp(scope = Cauldron::Scope.new)
      res = operators.collect do |operator|
        # begin
        operator.content.to_ruby(scope, operator.children)
        # rescue NoMethodError => e
        #   binding.pry
        # end
      end.join("\n")

      sexp = Ripper::SexpBuilder.new(res).parse
      sexp
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
      m = %{
        def function(#{problems.variables.join(',')})
          #{to_ruby(problems.scope)}
        end
      }
      o.instance_eval(m)

      # o.function *problems.examples.first.arguments
      problems.all? do |example|
        o.function(*example.arguments) == example.response
      end

    # TODO: Remove this resque - it is just a temp
    rescue NoMethodError => e
      false
    rescue NameError => e
      false
    rescue TypeError => e
      false
    end

    # TODO: Drop this method
    def successful?(problem)
      # # TODO track the parameters of the operator
      # operators.trace(problem)

      # # TODO For now just evalute the code
      # return true if problem[:arguments].first == problem[:response]
      # false

      pt = PryTester.new

      args = problem.arguments
      variables = problem.params # (0...args.length).collect {|x| 'var'+x.to_s}
      a = [
        'def function(' + variables.join(',') + ');' + to_ruby(variables) + '; end',
        'function(' + problem.arguments.collect { |x| to_programme(x) }.join(',') + ')'
      ]

      res = pt.eval(
        ['def function(' + variables.join(',') + ');' + to_ruby(variables) + '; end', 'function(' + problem.arguments.collect { |x| to_programme(x) }.join(',') + ')']
      )

      problem.response == res
    end

    def to_programme(value)
      return %('#{value}') if value.is_a?(String)

      value.to_s
    end

    # TODO: Add a safety evalutor
  end
end
