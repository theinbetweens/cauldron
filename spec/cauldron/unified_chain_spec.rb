require 'spec_helper'

module Cauldron
  
  describe 'UnifiedChain' do 
    
    describe '#theory_variables' do
      it 'gets the correct number of variables for demo 1' do
        temp = Object.new
        temp.extend(Cauldron::Demos)
        demo = temp.demo_one
        # => TODO Demos should probably only save unified chains
        unified_chain = demo[:chain].unify_chain
        unified_chain.theory_variables.length.should == 3           
      end
      it 'gets the correct number of variables for demo 2' do
        temp = Object.new
        temp.extend(Cauldron::Demos)
        demo = temp.demo_two
        unified_chain = demo[:chain].unify_chain
        unified_chain.theory_variables.length.should == 6       
        unified_chain.theory_variables.collect {|x| x.theory_variable_id}.uniq.length.should == 6 
      end
    end
    
    describe '#implementation_permuatations' do
      context 'when using demo one chain' do
        
        it 'creates the just one implementation permutation' do
          temp = Object.new
          temp.extend(Cauldron::Demos)
          demo = temp.demo_one
          unified_chain = demo[:chain].unify_chain
          test_cases = demo[:test_cases]
          pp test_cases
          unified_chain.implementation_permuatations(
            RuntimeMethod.new(MethodUsage.new(MethodParameter.new)),
            test_cases,
            Mapping.new
          )          
          
          unified_chain.implementation_permuatations(
            RuntimeMethod.new(MethodUsage.new(MethodParameter.new)),
            test_cases,
            Mapping.new
          ).length.should == 1
        end
        
      end
    end
    
  end

end
