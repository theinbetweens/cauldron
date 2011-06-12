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
      next_exp = exp.shift
      if next_exp.to_s.match(/var[|_]*(\d+)/)
        puts '--------------------->>>>>>>>>>>>>var8'
        puts $1
        s = Statement.new(Unknown.new($1),Equal.new)
        puts s.class
        puts s.write
      end
      pp exp
      a = process(exp.shift)
      puts a.class
      s.add a
      puts s.write
      return s
      # pp exp
      # puts exp.class
      # if next_exp.kind_of?(Symbol)
        # res = process(exp.shift)
        # s.add res
      # end
      # s
    end    
    
    def process_if(exp)      
      inner_statement_sexp = exp.shift
      # => Clear out the remain sexp 
      exp.shift
      exp.shift      
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
    
    def process_defn(exp)
      type = exp.shift
      args = exp.shift
      scope = exp.shift
      
      m = RuntimeMethod.new(MethodUsage.new)
      puts '---------------KKKKKKKKKKKKK'
      pp scope
      puts '---------------KKKKKKKKKKKKK'
      statement = process(scope)
      puts '---------------PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPp'
      puts statement.class
      m << statement unless statement.nil?
      return m
      
    end
    
    def process_scope(exp)
      return process(exp.shift)
    end
    
    def process_block(exp)
      a = exp.shift
      puts '----------------------MMMMMMMMMMMMMMMMMmmm'
      pp a
      puts a.class
      puts a.first
      #return nil if a.first.nil?
      puts a.first
      puts a.first.class
      if a.first == :nil
        puts '---------------- it is NILLLLLLLLLLLl'
        return nil
      end
      puts '----------------------MMMMMMMMMMMMMMMMMmmm'
      s = process(a)
      return s   
    end    
    
  end
  
  
end