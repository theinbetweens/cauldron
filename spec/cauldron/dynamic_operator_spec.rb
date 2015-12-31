require 'spec_helper'

module Cauldron
  
  describe DynamicOperator do

    describe '#extend_validation' do

      # PENDING - it should add more tracking as sexp
    end

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

        describe 'using incompatible variable' do

          context 'when var0 is 8' do

            let(:histories) do
              Cauldron::Histories.new([Cauldron::History.new([{var0: 8}])])
            end

            it 'saves the failed example' do
              expect{
                dynamic_operator.realizable?(histories)
              }.to change{
                dynamic_operator.failed_uses.length
              }.from(0).to(1)
            end

          end          

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

          let(:histories) do
            Cauldron::Histories.new(
              [Cauldron::History.new([{var0: 8}])]
            )
          end

          it 'returns false' do
            dynamic_operator.should_not be_realizable(histories)
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

          let(:histories) do
            Cauldron::Histories.new(
              [Cauldron::History.new([{var0: 'test'}])]
            )
          end

          it 'returns true' do
            dynamic_operator.should be_realizable(histories)
          end

          context 'when the history has "Sparky", "Kel"' do

            let(:histories) do
              Cauldron::Histories.new(
                [
                  Cauldron::History.new([{:var0=>"Sparky", :line=>0, :depth=>0, :total_line=>0}]),
                  Cauldron::History.new([{:var0=>"Kel", :line=>0, :depth=>0, :total_line=>0}])
                ]
              )
            end

            it 'returns true' do
              dynamic_operator.should be_realizable(histories)
            end            

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
        if File.exists? File.join('tmp', 'temp.rb')
          FileUtils.rm File.join('tmp', 'temp.rb')
        end
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