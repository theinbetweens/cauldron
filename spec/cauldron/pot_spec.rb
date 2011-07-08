require 'spec_helper'

module Cauldron
  
  describe 'Pot' do 
    
    describe '#simmer' do
      it 'can simmer with demo one' do 
        pot = Cauldron::Pot.new
        pot.clear
        lambda {pot.simmer(demo_one)}.should_not raise_error
      end
      it 'can simmer with demo two' do 
        pot = Cauldron::Pot.new
        pot.clear
        lambda {pot.simmer(demo_two)}.should_not raise_error        
      end
      it 'can simmer with both demo one and two' do
        pot = Cauldron::Pot.new
        pot.clear
        lambda {pot.simmer(demo_one)}.should_not raise_error
        lambda {pot.simmer(demo_two)}.should_not raise_error        
      end
    end
    
    describe '#brew' do
      it 'can come up with a solution after it has been given demo_one' do
        pot = Cauldron::Pot.new
        pot.clear
        pot.simmer(demo_one)
        cases = []
        cases << convert_to_example(separate_values("'sparky','sparky'"))
        cases << convert_to_example(separate_values("'kel','kel'"))
        
        ruby      =  "
            def method_0(var_0)
              \treturn var_0
            end
          "             
        parser    = RubyParser.new          
        sexp      = parser.process(ruby)
        sexp2cauldron = Sexp2Cauldron.new      
        pot.brew(cases).reset_ids!.basic_write.should == sexp2cauldron.process(sexp).basic_write  
      end
      
      it 'can come up with a solution that fits demo two' do
        pot = Cauldron::Pot.new
        pot.clear
        pot.simmer(demo_two)
        cases = []
        cases << convert_to_example(separate_values("'carrot','vegtable'"))
        cases << convert_to_example(separate_values("'fish','animal'"))
        
        ruby      =  "
                        def method_0(var_0)
                          \tif(var_0 == 'carrot')
                          \t\treturn 'vegtable'
                          \tend
                          \treturn 'animal'
                        end        
                     "
        parser    = RubyParser.new          
        sexp      = parser.process(ruby)
        sexp2cauldron = Sexp2Cauldron.new
        pot.brew(cases).reset_ids!.basic_write.should == sexp2cauldron.process(sexp).basic_write                     
      end
      
      context 'it has both demo one and two loaded' do
        before(:each) {
          @pot = Cauldron::Pot.new
          @pot.clear
          @pot.simmer(demo_one)
          @pot.simmer(demo_two)
        }
        it 'can generate a solution like demo 1' do
          cases = []
          cases << convert_to_example(separate_values("'pip','pip'"))
          cases << convert_to_example(separate_values("'rowiage','rowiage'"))
          ruby      =  "
            def method_0(var_0)
              \treturn var_0
            end
          "
          parser    = RubyParser.new          
          sexp      = parser.process(ruby)
          sexp2cauldron = Sexp2Cauldron.new      
          @pot.brew(cases).reset_ids!.basic_write.should == sexp2cauldron.process(sexp).basic_write                              
        end
        it 'can generate a solution like demo 2(it needs to discount the demo 1 solution)' do
          #pending('I need to tidy the generation process')
          cases = []
          cases << convert_to_example(separate_values("'sparky','bro'"))
          cases << convert_to_example(separate_values("'kel','sis'"))
          ruby      =  "
                          def method_0(var_0)
                            \tif(var_0 == 'sparky')
                            \t\treturn 'bro'
                            \tend
                            \treturn 'sis'
                          end        
                       "                    
          parser    = RubyParser.new          
          sexp      = parser.process(ruby)
          sexp2cauldron = Sexp2Cauldron.new
          @pot.brew(cases).reset_ids!.basic_write.should == sexp2cauldron.process(sexp).basic_write
        end
      end
      
    end
    
  end

end