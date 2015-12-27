require 'spec_helper'

module Cauldron

  describe ExampleSet do

    describe '#all?' do

      context %q{contains example {:arguments => ['Mass'], :response => 'effect'}} do

        context %q{with block {|x| x.response == 'effect'}} do

          let(:example_set) do
            Cauldron::ExampleSet.new(
              [
                Cauldron::Example.new({:arguments => ['Mass'], :response => 'effect'})
              ]
            )
          end

          it 'returns false' do
            example_set.all? {|x| x.response == 'effect'}.should == true
          end

        end

      end

    end

  end

end