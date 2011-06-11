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
      #type = exp.shift
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
      #exp.shift
      next_exp = exp.shift
      if next_exp.to_s.match(/var(\d+)/)
        s = Statement.new(Unknown.new($1),Equal.new)
      end
      
      if next_exp.kind_of?(Symbol)
        res = process(exp.shift)
        s.add res
      end
      s
    end    
    
    def process_if(exp)      
      inner_statement_sexp = exp.shift
      # => Clear out the remain sexp 
      exp.shift
      exp.shift      
      #return OpenStatement.new(IfContainer.new(*process(inner_statement_sexp)))
      return OpenStatement.new(Statement.new(If.new,Container.new(*process(inner_statement_sexp))))
    end    
    
    def process_call(exp)
      results = []
      a = exp.shift
      variable_id = a[2].to_s.match(/var(\d+)/)[1]
      var = Unknown.new(variable_id)
      results << var
      b = exp.shift
      c = exp.shift
      if b == :==
        results << Equivalent.new
      end
      results << process(c)
      return results
    end    
    
    def process_arglist(exp)
      return process exp.shift
    end
    
  end
  
  
end