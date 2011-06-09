require 'rubygems'
require 'sexp_processor'

module Cauldron
  
  class Sexp2Cauldron < SexpProcessor
    
    def initialize
      super
      self.strict = false
      self.expected = Object   
      @debug[:lasgn] = nil
      @unsupported_checked = true
    end
    
    def process_lit(exp)
      type = exp.shift
      val = exp.shift
      return Literal.new(val)
    end
    
    # def in_context type, &block
      # # puts '-------------------------- in_context'
      # # warn 'kadsjflkasj kldasfj lasdkfj ldksaf'
      # # puts type
      # # puts block_given?
      # # pp self.context
      # # puts @debug.has_key?(type)
      # # pp &block
      # # puts '--------------------999999999999999'
      # self.context.unshift type
#   
      # yield
#   
      # self.context.shift
    # end    
    
    # def process(exp)
        # puts '--------------------------------calling process===================>'
        # return nil if exp.nil?
        # exp = self.rewrite(exp) if self.context.empty?
        # puts '-------------------@unsupported_checked--------->>>>>>>>>>>.'
        # puts @unsupported_checked
        # puts '-------------------@unsupported_checked--------->>>>>>>>>>>.'
        # unless @unsupported_checked then
          # m = public_methods.grep(/^process_/) { |o| o.to_s.sub(/^process_/, '').to_sym }
          # supported = m - (m - @unsupported)
#     
          # raise UnsupportedNodeError, "#{supported.inspect} shouldn't be in @unsupported" unless supported.empty?
#     
          # @unsupported_checked = true
        # end
#     
        # result = self.expected.new
#     
        # type = exp.first
        # raise "type should be a Symbol, not: #{exp.first.inspect}" unless
          # Symbol === type
#     
        # in_context type do
#           
          # puts '==============================IN COTEXT('+exp.to_s+') ====================== '
#           
          # if @debug.has_key? type then
            # str = exp.inspect
            # puts "// DEBUG: #{str}" if str =~ @debug[type]
          # end
#     
          # exp_orig = nil
          # exp_orig = exp.deep_clone if $DEBUG or
            # @debug.has_key? type or @exceptions.has_key?(type)
#     
          # raise UnsupportedNodeError, "'#{type}' is not a supported node type" if
            # @unsupported.include? type
#     
          # if @debug.has_key? type then
            # str = exp.inspect
            # puts "// DEBUG (rewritten): #{str}" if str =~ @debug[type]
          # end
#     
          # # now do a pass with the real processor (or generic)
          # meth = @processors[type] || @default_method
          # if meth then
#     
            # if @warn_on_default and meth == @default_method then
              # warn "WARNING: Using default method #{meth} for #{type}"
            # end
#     
            # exp.shift if @auto_shift_type and meth != @default_method
#             
            # puts 'Calling method ----------'+meth.to_s
            # result = error_handler(type, exp_orig) do
              # self.send(meth, exp)
            # end
#     
            # raise SexpTypeError, "Result must be a #{@expected}, was #{result.class}:#{result.inspect}" unless @expected === result
#     
            # self.assert_empty(meth, exp, exp_orig) if @require_empty
          # else
            # unless @strict then
              # until exp.empty? do
                # sub_exp = exp.shift
                # sub_result = nil
                # if Array === sub_exp then
                  # sub_result = error_handler(type, exp_orig) do
                    # process(sub_exp)
                  # end
                  # raise "Result is a bad type" unless Array === sub_exp
                  # raise "Result does not have a type in front: #{sub_exp.inspect}" unless Symbol === sub_exp.first unless sub_exp.empty?
                # else
                  # sub_result = sub_exp
                # end
                # result << sub_result
              # end
#     
              # # NOTE: this is costly, but we are in the generic processor
              # # so we shouldn't hit it too much with RubyToC stuff at least.
              # #if Sexp === exp and not exp.sexp_type.nil? then
              # begin
                # result.sexp_type = exp.sexp_type
              # rescue Exception
                # # nothing to do, on purpose
              # end
            # else
              # msg = "Bug! Unknown node-type #{type.inspect} to #{self.class}"
              # msg += " in #{exp_orig.inspect} from #{caller.inspect}" if $DEBUG
              # raise UnknownNodeError, msg
            # end
          # end
#           
          # puts '--------------------------------DONE ---------------------- context'
#           
        # end
#     
        # result
      # end
#     
    # => Overwritten method
    def process_lasgn(exp)
      exp.shift
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
    
  end
  
  
end