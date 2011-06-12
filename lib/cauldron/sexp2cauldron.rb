require 'rubygems'
require 'ruby2ruby'
require 'sexp_processor'

module Cauldron
  
  class Sexp2Cauldron < SexpProcessor
    
    def initialize
      super
      self.expected = Object   
      self.auto_shift_type = true
      self.strict = true      
      @debug[:lasgn] = nil
      @unsupported_checked = true
    end
    
    def process_lit(exp)
      val = exp.shift
      return Literal.new(val)
    end
    
    def in_context type, &block
      self.context.unshift type
      yield
      self.context.shift
    end    
    
    def process_str(exp)
      Literal.new(exp.shift)
    end
    
    # => Overwritten method
    def process_lasgn(exp)
      next_exp = exp.shift
      if next_exp.to_s.match(/var[|_]*(\d+)/)
        s = Statement.new(Unknown.new($1),Equal.new)
      end
      a = process(exp.shift)
      s.add a
      return s
    end    
    
    def process_if(exp)
      inner_statement_sexp = exp.shift 
      scope = process(exp.shift)   # => The content of the if statement
      exp.shift
      open_statement = OpenStatement.new(Statement.new(If.new,Container.new(*process(inner_statement_sexp))))
      open_statement << scope unless scope.nil?
      return open_statement
    end    
    
    def process_return(exp)
      s = Statement.new(Return.new,*process(exp.shift))
      return s
    end
    
    def process_call(exp)
      results = []
      until exp.empty?
        atom = exp.shift
        # => TODO NOt DRY RegExp
        if atom.to_s.match(/var[|_]*(\d+)/)
          variable_id = atom.to_s.match(/var[|_]*(\d+)/)[1]
          results << Unknown.new(variable_id)
          next
        end
        if atom == :==
          results << Equivalent.new
          next
        end   
        next if atom.nil?
        res = process(atom)
        next if res.nil?
        results << res     
      end
      return results
    end    
    
    def process_arglist(exp)
      return process exp.shift
    end
    
    def process_defn(exp)
      type = exp.shift
      args = exp.shift
      scope = exp.shift
      
      pp args
      puts args.length
      usage = (args.length==2) ? process(args) : MethodUsage.new
      
      method = RuntimeMethod.new(usage)
      statements = process(scope)
      unless statements.nil?
        statements.each do |statement|
          puts statement.class.to_s
          method << statement unless statement.nil?
        end
      end
      return method
      
    end
    
    def process_args(exp)
      atom = exp.shift
      variable_id = atom.to_s.match(/var[|_]*(\d+)/)[1]
      param = MethodParameter.new()
      param.variable_id = variable_id
      return MethodUsage.new(param)
    end
    
    def process_scope(exp)
      block = exp.shift
      res = process(block)
      return res
    end
    
    def process_block(exp)
      result = []   
      until exp.empty?
        atom = exp.shift
        next if atom.first == :nil
        result << process(atom)
      end
      return result
    end    
    
  end
  
  
end