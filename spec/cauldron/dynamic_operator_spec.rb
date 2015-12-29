require 'spec_helper'

module Cauldron
  
  describe DynamicOperator do

    describe '#build' do

      let(:dynamic_operator) do
        StatementGenerator.new.build('string',[:chop]).first
      end      

      it 'returns a instance of DynamicOperator' do
        dynamic_operator.build([0]).should be_instance_of(DynamicOperator)
      end

      it 'returned instance responds to #instances' do
        dynamic_operator.build([0]).respond_to?(:instances).should == true
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