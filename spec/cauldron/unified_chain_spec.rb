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
        
        it 'creates just one implementation permutation' do
          temp = Object.new
          temp.extend(Cauldron::Demos)
          demo = temp.demo_one
          unified_chain = demo[:chain].unify_chain
          test_cases = demo[:test_cases]   
          
          unified_chain.implementation_permuatations(
            RuntimeMethod.new(MethodUsage.new(MethodParameter.new)),
            test_cases,
            Mapping.new
          ).length.should == 1
        end
        
        it 'is a unified chain' do 
          temp = Object.new
          temp.extend(Cauldron::Demos)
          demo = temp.demo_one
          unified_chain = demo[:chain].unify_chain
          test_cases = demo[:test_cases]   
                    
          unified_chain.implementation_permuatations(
            RuntimeMethod.new(MethodUsage.new(MethodParameter.new)),
            test_cases,
            Mapping.new
          )[0].should be_kind_of(ImplementedChain)          
          
          unified_chain.implementation_permuatations(
            RuntimeMethod.new(MethodUsage.new(MethodParameter.new)),
            test_cases,
            Mapping.new
          )[0].write.should_not include('var')          
          
        end
        context 'when using demo two' do
          it 'creates just one implementation permutation' do
            temp = Object.new
            temp.extend(Cauldron::Demos)
            demo = temp.demo_two
            unified_chain = demo[:chain].unify_chain   
            test_cases = demo[:test_cases]   
          
            unified_chain.implementation_permuatations(
              RuntimeMethod.new(MethodUsage.new(MethodParameter.new)),
              test_cases,
              Mapping.new
            ).length.should == 1
                
            # unified_chain.implementation_permuatations(
              # RuntimeMethod.new(MethodUsage.new(MethodParameter.new)),
              # test_cases,
              # Mapping.new
            # )[0].write.should_not include('var')              
                             
          end
        end
      end
      
      describe '#mapping_permutations' do
        before(:each) {
          temp = Object.new
          temp.extend(Cauldron::Demos)
          demo = temp.demo_one
          @unified_chain = demo[:chain].unify_chain          
        }
        it 'should create four permutations with one variable id and four values' do
          values = [IntrinsicRuntimeMethod.new,IntrinsicTestCases.new,IntrinsicLiteral.new(0),IntrinsicLiteral.new(1)]
          @unified_chain.mapping_permutations([0],values).length.should == 4
        end
        it 'should create 9 permutations with three variable id and three values' do
          values = [IntrinsicRuntimeMethod.new,IntrinsicTestCases.new,IntrinsicLiteral.new(1)]
          @unified_chain.mapping_permutations([0,1,2],values).length.should == 6
        end
      end
      
    end
    
  end

end
