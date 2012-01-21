require 'rubygems'
require 'ruby2ruby'
require 'sexp_processor'

module Cauldron
  
  class Sexp2Cauldron < Ruby2Ruby
    
    VARIABLE_EXPRESSION = /var[|_]*(\d+)/
    
    def initialize
      super
      self.expected = Object   
      self.auto_shift_type = true
      self.strict = true      
      @debug[:lasgn] = nil
      @unsupported_checked = true
    end
    
    def process(ruby)
      parser    = RubyParser.new
      sexp      = parser.process(ruby)
      debugger      
      super(sexp)
    end
    
    def process_lit(exp)
      #debugger
      obj = exp.shift
      case obj
      when Range then
        "(#{obj.inspect})"
      else
        obj.inspect
        Literal.new(obj)
      end      
      #val = exp.shift
      #return Literal.new(val)
    end
    
    def process_const(exp)
      #raise StandardError.new(exp.shift.to_s)
      exp.shift.to_s
      RuntimeMethodClass.new
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
      if next_exp.to_s.match(VARIABLE_EXPRESSION)
        s = Statement.new(convert_to_variable(next_exp),Equal.new)
      end
      a = process(exp.shift)
      s.add a
      return s
    end    
    
    def process_if(exp)
      
      #expand = Ruby2Ruby::ASSIGN_NODES.include? exp.first.first
      #c = process exp.shift
      #t = process exp.shift
      #f = process exp.shift
      #debugger      
      
      inner_statement_sexp = exp.shift 
      scope = process(exp.shift)   # => The content of the if statement
      exp.shift
      open_statement = OpenStatement.new(Statement.new(If.new,Container.new(process(inner_statement_sexp))))
      open_statement << scope unless scope.nil?
      return open_statement
    end    
    
    def process_return(exp)
      return Statement.new(Return.new,process(exp.shift))
    end
    
    def process_call(exp)

      ############### Copy and Paste from Ruby2Ruby ##########
      
      receiver_node_type = exp.first.nil? ? nil : exp.first.first
      receiver = process exp.shift
  
      receiver = "(#{receiver})" if
        Ruby2Ruby::ASSIGN_NODES.include? receiver_node_type
  
      name = exp.shift
      args = []
      
      # this allows us to do both old and new sexp forms:
      exp.push(*exp.pop[1..-1]) if exp.size == 1 && exp.first.first == :arglist
  
      @calls.push name
  
      in_context :arglist do
        until exp.empty? do
          #debugger
          arg = process exp.shift
          #args << arg unless arg.empty?
          args << arg unless arg.nil?
        end
      end            
      
      ############################### END COPY #########################
      args     = nil                    if args.empty?
      #args     = "(#{args.join(', ')})" if args
      #receiver = "#{receiver}."         if receiver
      
      if name.to_s.match(VARIABLE_EXPRESSION)
        puts '-------------------Receiver is '
        #return convert_to_variable(name)
        puts name
        var = convert_to_variable(name)
        return var
      end
      
      
      case name
      when *BINARY then
        # TODO This should receiver, name, args foramt - the call should be with the receiver
        return Statement.new(receiver,Equivalent.new,*args)
      else
        receiver_method_call =  case name 
                                when :kind_of?
                                  KindOf.new
                                when :params
                                  Params.new
                                when :[]
                                  #Statement.new(receiver,Container.new(*args))
                                  puts 'RESULT------'
                                  puts receiver.write
                                  return Statement.new(ArrayAccess.new(receiver,args))
                                end
                                #debugger
        return Statement.new(receiver,receiver_method_call,Container.new(*args))
        #"#{receiver}#{name}#{args}"
      end
      
      # results = []
      # until exp.empty?
#         
        # atom = exp.shift
        # if atom.to_s.match(VARIABLE_EXPRESSION)
          # results << convert_to_variable(atom)
          # next
        # end
        # if atom == :==
          # results << Equivalent.new
          # next
        # end   
        # next if atom.nil?
        # res = process(atom)
        # next if res.nil?
        # results << res     
      # end
      # return Statement.new(*results)
    ensure
      @calls.pop
    end  
    
    def process_arglist(exp)
      return process exp.shift
    end
    
    def process_defn(exp)
      type = exp.shift
      args = exp.shift
      scope = exp.shift
      
      usage = (args.length==2) ? process(args) : MethodUsage.new
      method_id = type.to_s.match(/method_(\d)+/)[1]
      method = RuntimeMethod.new(usage,method_id)
      statements = process(scope)
      unless statements.nil?
        statements.each do |statement|
          method << statement unless statement.nil?
        end
      end
      return method
      
    end
    
    def process_args(exp)
      atom = exp.shift
      variable_id = atom.to_s.match(VARIABLE_EXPRESSION)[1]
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
    
    def process_lvar(exp)
      var = exp.shift
      return convert_to_variable(var)
    end
    
  private
   
    def convert_to_variable(variable)
      return Unknown.new(variable.to_s.match(VARIABLE_EXPRESSION)[1])
    end
    
  end
  
  
end