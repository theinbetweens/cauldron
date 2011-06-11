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
        puts '------------------------>>>>>>>'
        puts sexp2cauldron.process(sexp).write
        puts '------------------------>>>>>>>'
        sexp      = parser.process(ruby)
        sexp2cauldron.process(sexp).write.should == "if(var_5 == 6)\nend"        
      end
      
    end
  end
  
end