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
        #pot.brew(cases).basic_write.should == sexp2cauldron.process(sexp).basic_write
      end
      
    end
    
  end

end