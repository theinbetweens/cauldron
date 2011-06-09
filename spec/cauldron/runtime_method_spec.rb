require 'spec_helper'

def fetch_runtime
  
  basic_runtime = %q!
    def method_1(var_2)
      return var_2
    end
  !
  puts basic_runtime
  res = eval(basic_runtime)
  sexp = RubyParser.new.process(basic_runtime)  
  p Ruby2Ruby.new.process(sexp)
  
end


module Cauldron
  
   describe 'RuntimeMethod' do
     
    describe '#basic_write' do
      
      # => TODO I need a factory or better way to write the runtime methods
      it 'should return a string of the built method without comment information' do 
        method_param = MethodParameter.new
        temporary_runtime_method = RuntimeMethod.new(MethodUsage.new(method_param))
        temporary_runtime_method << Statement.new(Return.new,method_param)
        temporary_runtime_method.basic_write.should == "def method_2(var_4)\n\treturn var_4\nend\n"
      end
      
    end
     
   end
   
end