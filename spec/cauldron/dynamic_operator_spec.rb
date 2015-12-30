require 'spec_helper'

module Cauldron
  
  describe DynamicOperator do

    describe '#build' do

      let(:dynamic_operator) do
        StatementGenerator.new.build('string',[:chop]).first
      end      

      it 'returns a instance of DynamicOperator' do
        dynamic_operator.init([0]).should be_instance_of(DynamicOperator)
      end

      it 'returned instance responds to #instances' do
        dynamic_operator.init([0]).respond_to?(:instances).should == true
      end      

    end

    describe '#realizable?' do

      context 'var0.chop' do

        let(:dynamic_operator) do
          StatementGenerator.new.build('string',[:chop]).first.init([0])
        end

        let(:composite) do
          Cauldron::Solution::Composite.new(
            [ Tree::TreeNode.new("CHILD1", dynamic_operator.init([0]) ) ]
          )
        end        

        context 'when var0 is 8' do

          let(:scope) { Cauldron::Scope.new(['var0']) }

          let(:examples) do
            Cauldron::ExampleSet.new(
              [
                Cauldron::Example.new({arguments: [8], response: 8}),
              ]
            )
          end

          it 'returns false' do
            dynamic_operator.should_not be_realizable(composite,examples)
          end

        end

        context 'when var0 is "test"' do

          let(:scope) { Cauldron::Scope.new(['var0']) }

          let(:examples) do
            Cauldron::ExampleSet.new(
              [
                Cauldron::Example.new({arguments: ['test'], response: 'sdsas'}),
              ]
            )
          end          

          it 'returns true' do
            dynamic_operator.should be_realizable(composite,examples)
          end

        end        

      end

    end

    describe '#write_to_file' do

      let(:filename) { 'temp.rb' }

      let(:sexp) do
[:program,
 [:stmts_add,
  [:stmts_new],
  [:def,
   [:@ident, "test", [2, 4]],
   [:paren,
    [:params, [[:@ident, "var0", [2, 9]]], nil, nil, nil, nil, nil, nil]],
   [:bodystmt,
    [:stmts_add,
     [:stmts_new],
     [:call,
      [:var_ref, [:@ident, "var0", [3, 2]]],
      :".",
      [:@ident, "bounce", [3, 7]]]],
    nil,
    nil,
    nil]]]]        
      end

      let(:dynamic_operator) do
        DynamicOperator.new({}, sexp)
      end

      before(:each) do
        FileUtils.rm File.join('tmp', 'temp.rb')
      end

      it 'creates a file "tmp/temp.rb"' do
        expect{
          dynamic_operator.write_to_file('temp.rb')
        }.to change{
          File.exists?( File.join('tmp', 'temp.rb') )
        }.from(false).to(true)
      end

    end

  end

end