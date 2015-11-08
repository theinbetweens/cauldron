require 'spec_helper'

module Cauldron
  
  describe VarCollectOperator do

    let(:operator) do
      VarCollectOperator.new([0])
    end

    describe '#to_ruby' do

      it %q{is 
var1 = var0.collect do |x|
  x
end        
} do
        operator.to_ruby(['var0']).should == %{
var1 = var0.collect do |x| x end          
}.strip
      end


    end

  end

end