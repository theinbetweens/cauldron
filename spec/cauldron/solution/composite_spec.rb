require 'spec_helper'

module Cauldron::Solution
  
  describe 'Composite' do

    describe '#to_ruby' do

      context 'first line' do

        context 'has operator "Array#collect"' do

          let(:array_collect) { ArrayCollect.new([0]) }

          context 'has operator "String#*"' do

            let(:string_asterisk) { StringAsteriskOperator.new([1],2) }

            let(:composite) { Composite.new() }

            it 'is "var0.collect {|x| x * 2} "' do
              Cauldron::Solution::Composite.new(
                [array_collect, string_asterisk]
              ).to_ruby(['var0']).should == 'var0.collect { |x| x * 2 }'
            end

          end

        end

      end

      context %q{with the operators} do 

        it %q{generates the code} do
          Composite.new(
            [ArrayCollect.new([0]), NumericOperator.new(2, [1]) ],
            [ArrayCollect.new([2]), ToSOperator.new]
          ).to_ruby(['var0']).should == %q{
  var1 = var0.collect do |x|
    x + 2
  end
  var2 = var1.collect do |x|
    x.to_s
  end
  }
        end

      end      

    end

    describe '#sexp' do

      context 'using initial operator "Array#collect"' do

        let(:collect_operator) { ArrayCollect.new([0]) }

        context 'using second operator "x * 3"' do

          let(:string_multiple) { StringAsteriskOperator.new([1],3) }

          it 'returns "var0.collect {|x| x + 3}"' do
            Composite.new([collect_operator, string_multiple]).sexp(['var0']).should == [
              :method_add_block, 
              [:call, 
                [:vcall, 
                  [:@ident, "var0"]
                ], 
                :".", 
                [:@ident, "collect"]
              ], 
              [:brace_block, 
                [
                  :block_var, 
                  [:params, [[:@ident, "x"]]]
                ], 
                [
                  :stmts_add, 
                  [:stmts_new], 
                  [
                    :binary, 
                    [:vcall, [:@ident, "x"]], 
                    :*, 
                    [:@int, 3]
                  ]
                ]
              ]
            ]
          end

        end

      end

    end

  end
  
end