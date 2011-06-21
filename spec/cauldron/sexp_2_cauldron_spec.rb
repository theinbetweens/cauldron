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
          def method_4
          end
        !
        sexp      = parser.process(ruby)
        sexp2cauldron = Sexp2Cauldron.new
        sexp2cauldron.process(sexp).basic_write.should == strip_whitespace(ruby)+"\n"        
      end
      
      it 'generates a method with a simple statement' do 
        parser    = RubyParser.new
        ruby      =  "
          def method_3
            \tvar_8 = 9
          end
        "
        sexp      = parser.process(ruby)
        sexp2cauldron = Sexp2Cauldron.new
        a = sexp2cauldron.process(sexp)
        a.basic_write.should == strip_whitespace(ruby)+"\n"
      end
      
      it 'generates a method with a simple if statement' do
        parser    = RubyParser.new
        ruby      =  "
          def method_6
            \tif(var_8 == 9)
            \t\treturn var_8
            \tend
          end
        "
        sexp2cauldron = Sexp2Cauldron.new        
        sexp      = parser.process(ruby)
        sexp2cauldron.process(sexp).basic_write.should == strip_whitespace(ruby)+"\n"        
      end
      
      it 'generates a method with an if statement and two exit points' do 
        parser    = RubyParser.new
        ruby      =  "
          def method_3(var_0)
            \tif(var_0 == 'apple')
            \t\treturn 'fruit'
            \tend
            \treturn 'vegetable'
          end
        "
        sexp2cauldron = Sexp2Cauldron.new        
        sexp      = parser.process(ruby)
        sexp2cauldron.process(sexp).basic_write.should == strip_whitespace(ruby)+"\n"        
      end
      
      it 'generates the solution to demo 1' do
        parser    = RubyParser.new
        ruby      =  "
          def method_0(var_0)
            \treturn var_0
          end
        "
        sexp2cauldron = Sexp2Cauldron.new        
        sexp      = parser.process(ruby)
        sexp2cauldron.process(sexp).basic_write.should == strip_whitespace(ruby)+"\n"         
      end
      
      it 'can parse the solution to demo 2' do
        parser    = RubyParser.new
        ruby      =  "
          def method_0(var_0)
            \tif(var_0 == 'fish')
            \t\treturn 'animal'
            \tend
            \treturn 'vegtable'
          end
        "
        sexp2cauldron = Sexp2Cauldron.new        
        sexp      = parser.process(ruby)
        sexp2cauldron.process(sexp).basic_write.should == strip_whitespace(ruby)+"\n"         
      end
      
    end
  end
  
end