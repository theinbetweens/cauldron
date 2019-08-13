require 'spec_helper'

module Cauldron::ArrayCollectTemplate
  
  describe Default do

    describe '#context_realizable?' do

      context 'var2 is "Sparky"' do

        let(:context) do
          {:var2=>"Sparky", :var0=>["Sparky", "Kels"], :var1=>nil, :line=>0, :depth=>1, :total_line=>2, :point=>[0, 0]}
        end

        context 'using the index "2"' do

          let(:subject) { Cauldron::ArrayCollectTemplate::Default.new([2]) }

          it 'is false' do
            subject.context_realizable?(context).should == false
          end

        end

        context 'using the index "0"' do

          let(:subject) { Cauldron::ArrayCollectTemplate::Default.new([0]) }

          it 'is true' do
            subject.context_realizable?(context).should == true
          end

        end        

      end

    end

  end

end