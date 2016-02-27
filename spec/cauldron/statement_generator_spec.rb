require 'spec_helper'

module Cauldron

  describe StatementGenerator do

    describe '#build_class' do

      let(:subject) { StatementGenerator.new}

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

    describe '#build' do

      let(:subject) { StatementGenerator.new}

      it 'returns 1 operator' do
        subject.build('string',[:chop]).should have(1).operator
      end

      it 'returns a instance that responds false to #uses_constants?' do
        subject.build('string',[:chop]).first.uses_constants?.should == false
      end

      it 'returns a instance that returns an instance with #build' do
        subject.build('string',[:chop]).first.init([0]).should be_instance_of(DynamicOperator)
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
            subject.build('string',[:chop]).first.build([0])
          end

        end

        describe '#to_ruby' do

          let(:operator) do
            subject.build('string',[:chop]).first.init([0])
          end

          it 'returns the "var0.chop"' do
            operator.to_ruby(scope).should == 'var0.chop'
          end

        end

        describe '#instances' do

           # @results=
           #  [#<Cauldron::History:0x007fa02b00f848
           #    @logs=
           #     [{:var2=>"Sparky", :var0=>["Sparky", "Kels"], :var1=>nil, :line=>0, :depth=>1, :total_line=>3, :point=>[0, 0]},
           #      {:var2=>"Kels", :var0=>["Sparky", "Kels"], :var1=>nil, :line=>0, :depth=>1, :total_line=>3, :point=>[0, 0]},
           #      {:var0=>["Sparky", "Kels"], :var1=>["Sparky", "Kels"], :line=>0, :depth=>0, :total_line=>4, :point=>[1]}]>,
           #   #<Cauldron::History:0x007fa02cb63040
           #    @logs=
           #     [{:var2=>"Pip", :var0=>["Pip", "Rowe"], :var1=>nil, :line=>0, :depth=>1, :total_line=>3, :point=>[0, 0]},
           #      {:var2=>"Rowe", :var0=>["Pip", "Rowe"], :var1=>nil, :line=>0, :depth=>1, :total_line=>3, :point=>[0, 0]},
           #      {:var0=>["Pip", "Rowe"], :var1=>["Pip", "Rowe"], :line=>0, :depth=>0, :total_line=>4, :point=>[1]}]>]>          
          it 'returns 1 instance (at point [0,0])' do
            pending
            # See Builder#insertable_operators
          end

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
                    StatementGenerator.new.build(
                      ["Sparky", "Kels"],
                      [:collect]
                    ).first.init([0])                    
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
              subject.build('string',[:chop]).first
            end            

            # instances(histories, composite, examples, insert_points)
            it 'returns 1 new composite' do
              operator.instances(
                histories, composite, examples, insert_points
              ).should have(1).composites
            end

          end

        end

        describe '#to_tracking_sexp' do

          let(:operator) do
            subject.build('string',[:chop]).first.init([0])
          end

          it "doesn't raise an error" do
            operator.to_tracking_sexp([], scope, Cauldron::Caret.new).should match_code_of %q{
              var0.chop
            %}
          end

        end

      end

    end

  end

end