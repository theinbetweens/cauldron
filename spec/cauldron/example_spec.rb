require 'spec_helper'

module Cauldron
  
  describe Example do

    describe '#params' do

      let(:example) do
        Cauldron::Example.new(
          { arguments: [["Pip", "Rowe"]], response: ["Pi", "Row"] }
        )
      end

      it "returns ['var0']" do
        example.params.should == ['var0']
      end

      context '#params has already been called' do

        before(:each) { example.params }

        it "returns ['var0']" do
          example.params.should == ['var0']
        end        

      end

    end

  end

end