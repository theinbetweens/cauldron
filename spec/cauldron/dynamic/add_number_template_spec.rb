module Cauldron

  describe 'DynamicNumberAddition' do

    let(:generator) do
      StatementGenerator.new.build_template(4, '+')
    end

    context 'given the example a = 4; return 6' do

      let(:examples) do
        Cauldron::ExampleSet.new(
          [
            Cauldron::Example.new({arguments: [4], response: 6}),
          ]          
        )
      end

      it 'generates a statement a + 2' do
        pending
        generator.statement_classes(examples).should include_statement("a + 2")
      end

    end

  end

end