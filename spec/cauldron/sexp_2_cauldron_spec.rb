require 'spec_helper'

module Cauldron
  
  describe "Sexp2Cauldron" do
    describe "#process" do
      it "Generates a cauldron literal from a sexp literal" do
        parser    = RubyParser.new
        ruby      = "8"
        sexp      = parser.process(ruby)
        sexp2cauldron = Sexp2Cauldron.new      
        sexp2cauldron.process(sexp).write.should == Literal.new(8).write        
      end      
      
      it "Generates a basic cauldron statement" do
        parser    = RubyParser.new
        ruby      = "var4 = 9"
        sexp      = parser.process(ruby)
        sexp2cauldron = Sexp2Cauldron.new
        sexp2cauldron.process(sexp).write.should == Statement.new(Unknown.new(4),Equal.new,Literal.new(9)).write        
      end
      
      it 'generates a basic if container' do 
        parser    = RubyParser.new
        ruby      =  %q!
          if(var5 == 6)
          end
        !
        sexp      = parser.process(ruby)
        sexp2cauldron = Sexp2Cauldron.new
        sexp      = parser.process(ruby)
        sexp2cauldron.process(sexp).write.should == "if(var_5 == 6)\nend"        
      end
      
      it 'generates an empty runtime method' do
        parser    = RubyParser.new
        ruby      =  %q!
          def method_0
          end
        !
        sexp      = parser.process(ruby)
        sexp2cauldron = Sexp2Cauldron.new
        sexp2cauldron.process(sexp).basic_write.should == strip_whitespace(ruby)+"\n"        
      end
      
      it 'generates a method with a simple statement' do 
        parser    = RubyParser.new
        ruby      =  %q!
          def method_1
            var_8 = 9
          end
        !
        ruby2 = "
          def method_1
            \t\tvar_8 = 9
          end
        "
        sexp      = parser.process(ruby)
        sexp2cauldron = Sexp2Cauldron.new
        #sexp2cauldron.process(sexp).basic_write.should == strip_whitespace(ruby2)+"\n"
        #strip_whitespace(ruby2)        
        sexp2cauldron.process(sexp).basic_write.should == strip_whitespace(ruby2)+"\n"
      end
      
    end
  end
  
end