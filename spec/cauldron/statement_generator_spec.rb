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