require 'spec_helper'

module Cauldron
  
  describe VarCollectOperator do

    it_behaves_like "operator" do
      let(:operator) { VarCollectOperator.new([0]) }
      let(:initial_scope) { Cauldron::Scope.new(['var0']) }
      let(:initial_operators) { [] }
    end    

    let(:operator) do
      VarCollectOperator.new([0])
    end

    let(:scope) do
      Cauldron::Scope.new(['var0'])
    end

    describe '#to_ruby' do

      it %q{is 
var1 = var0.collect do |var2|
  var2
end        
} do
        operator.to_ruby(scope,[]).should == %{
var1 = var0.collect do |var2| var2 end          
}.strip
      end


    end

  end

end