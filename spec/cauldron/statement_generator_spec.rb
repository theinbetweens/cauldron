require 'spec_helper'

module Cauldron

  describe StatementGenerator do

    describe '#method_to_sexp' do

      let(:subject) { StatementGenerator.new}

      context 'instance is "3"' do

        let(:instance) { 3 } 

        context 'dynamic_method is ":+"' do

          let(:dynamic_method) { :+ } 

          it "doesn't raise an error" do
            expect{
              subject.method_to_sexp(instance, dynamic_method)
            }.not_to raise_error
          end

        end

      end

    end

    describe '#build_class' do

      let(:subject) { StatementGenerator.new }

      context 'with string instance "string"' do

        context 'with method "chop"' do

          it "doesn't raise an error" do
            expect{
              subject.build_class('string', 'chop')
            }.not_to raise_error
          end

        end

      end

    end

    describe '#dynamic_template_name' do

      context 'with instance 4' do

        context 'with method "+"' do

          let(:subject) do
            Object.const_set(
              StatementGenerator.new.dynamic_template_name(4,'+'),
              Class.new
            )            
          end

          it 'generates a valid class name' do
            expect{
              subject.new
            }.not_to raise_error
          end

          after(:each) do
            Object.send(:remove_const, StatementGenerator.new.dynamic_template_name(4,'+'))
          end

        end

      end

    end

    describe '#build_template' do

      let(:subject) { StatementGenerator.new}

      context 'with instance 4' do

        context 'with method "+"' do

          it "doesn't raise an error" do
            expect{ subject.build_template(4, '+') }.not_to raise_error
          end

        end

      end

    end

    describe '#build' do

      let(:subject) { StatementGenerator.new}

      it 'returns 1 operator' do
        expect(subject.build('string',[:chop]).length).to eql(1)
      end

      describe 'generating String#chop' do

        let(:operators) { [] }
        let(:scope) { Cauldron::Scope.new(['var0']) }

        describe 'unbuilt instance' do

          it 'returns a instance that raises an error when #to_tracking_sexp' do
            expect{
              subject.build(
                'string',[:chop]
              ).first.to_tracking_sexp(
                operators, scope, Cauldron::Caret.new
              )
            }.to raise_error(StandardError)
          end

        end

        describe '#realizable?' do

          let(:operator) do
            subject.default_template('string',:chop).new([0])
          end

        end

        describe '#to_ruby' do

          let(:operator) do
            subject.default_template('string',:chop).new([0])
          end

          it 'returns the "var0.chop"' do
            operator.to_ruby(scope,[]).should == 'var0.chop'
          end

        end

        describe '#instances' do

          describe 'adding String#chop in collect statement' do

            let(:histories) do
              Cauldron::Histories.new(
                [
                  Cauldron::History.new(
                    [
                      {:var2=>"Sparky", :var0=>["Sparky", "Kels"], :var1=>nil, :line=>0, :depth=>1, :total_line=>3, :point=>[0, 0]},
                      {:var2=>"Kels", :var0=>["Sparky", "Kels"], :var1=>nil, :line=>0, :depth=>1, :total_line=>3, :point=>[0, 0]},
                      {:var0=>["Sparky", "Kels"], :var1=>["Sparky", "Kels"], :line=>0, :depth=>0, :total_line=>4, :point=>[1]}
                    ]
                  )
                ]
              )
            end

            let(:composite) do
              Cauldron::Solution::Composite.new(
                [
                  Tree::TreeNode.new(
                    "ROOT", 
                    StatementGenerator.new.default_template(
                      ["Sparky", "Kels"],
                      :collect
                    ).new([0])                    
                  )
                ]
              )
            end

            let(:examples) do
              Cauldron::ExampleSet.new(
                [
                  Cauldron::Example.new({arguments: [["Sparky", "Kels"]], response: ["Spark", "Kel"]}),
                  Cauldron::Example.new({arguments: [["Pip", "Rowe"]], response: ["Pi", "Row"]})
                ]
              )
            end

            let(:insert_points) { [[0, 0], [1]] }

            let(:operator) do
              subject.default_template('string',:chop)
            end            

            # instances(histories, composite, examples, insert_points)
            it 'returns 1 new composite' do
              expect(
                operator.instances(
                  histories, composite, examples, insert_points
                ).length
              ).to eql(1)
            end

          end

        end

      end

    end

  end

end