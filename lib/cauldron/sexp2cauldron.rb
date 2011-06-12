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
      
      method = RuntimeMethod.new(MethodUsage.new)
      statement = process(scope)
      method << statement unless statement.nil?
      return method
      
    end
    
    def process_scope(exp)
      return process(exp.shift)
    end
    
    def process_block(exp)
      a = exp.shift
      return nil if a.first == :nil
      s = process(a)
      return s   
    end    
    
  end
  
  
end