require 'spec_helper'

module Cauldron

  describe StatementGenerator do

    describe '#build' do

      let(:subject) { StatementGenerator.new}

      it 'returns 1 operator' do
        subject.build('string',[:chop]).should have(1).operator
      end

      it 'returns a instance that responds false to #uses_constants?' do
        subject.build('string',[:chop]).first.uses_constants?.should == false
      end

      it 'returns a instance that returns an instance with #build' do
        subject.build('string',[:chop]).first.build([0]).should be_instance_of(DynamicOperator)
      end      

    end

  end

end