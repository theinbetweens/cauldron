require 'spec_helper'

def fetch_runtime
  
  basic_runtime = %q!
    def method_1(var_2)
      return var_2
    end
  !
  res = eval(basic_runtime)
  sexp = RubyParser.new.process(basic_runtime)  
  
end


module Cauldron
  
   describe 'RuntimeMethod' do
     
    describe '#basic_write' do
      # => TODO I need a factory or better way to write the runtime methods
      it 'should return a string of the built method without comment information' do 
        method_param = MethodParameter.new
        temporary_runtime_method = RuntimeMethod.new(MethodUsage.new(method_param))
        temporary_runtime_method << Statement.new(Return.new,method_param)
        temporary_runtime_method.reset_ids!.basic_write.should == "def method_0(var_0)\n\treturn var_0\nend\n"
      end
    end
    
    describe '#reset_ids!' do
      context 'runtime method is empty' do
        it 'should return a new runtime method with the method id and variables starting from 0(this is for comparision)' do 
          parser    = RubyParser.new
          ruby      =  "
            def method_8
            end
          "
          sexp      = parser.process(ruby)
          sexp2cauldron = Sexp2Cauldron.new
          unprocessed_runtime_method = sexp2cauldron.process(sexp)
          reset_runtime_method = unprocessed_runtime_method.reset_ids!        
          reset_runtime_method.method_id.should == '0'  
        end
      end
      context 'using runtime method with if statement' do
        it 'should reset all the ids to 0 and count up' do
          parser    = RubyParser.new
          ruby      =  "
            def method_3(var_8)
              \tif(var_8 == 'apple')
              \t\treturn 'fruit'
              \tend
              \treturn 'vegetable'
            end
          "        
          sexp      = parser.process(ruby)
          sexp2cauldron = Sexp2Cauldron.new                  
          unprocessed_runtime_method = sexp2cauldron.process(sexp)  
          reset_runtime_method = unprocessed_runtime_method.reset_ids!
          reset_runtime_method.method_id.should == '0'
          reset_runtime_method.variables.length.should == 1
          
          ruby_reset      =  "
            def method_0(var_0)
              \tif(var_0 == 'apple')
              \t\treturn 'fruit'
              \tend
              \treturn 'vegetable'
            end
          "          
          reset_runtime_method.basic_write.should == strip_whitespace(ruby_reset)+"\n"
        end
      end
    end
    
    describe '#realise2' do
      it 'should be able to realise a very simple runtime method' do
        parser    = RubyParser.new
        ruby      =   "
                      def method_3
                        var_13 = 8
                      end
                      " 
        sexp      = parser.process(ruby)   
        sexp2cauldron = Sexp2Cauldron.new
        runtime_method = sexp2cauldron.process(sexp)
        runtime_method.realise2(ParametersContainer.new).class.should == RealisedRuntimeMethod           
      end  
    end
     
   end
   
end