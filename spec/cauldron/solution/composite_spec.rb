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

            let(:variables) { Cauldron::Scope.new(['var0']) }

            it 'is "var0.collect { |var1| var1 * 2 }"' do
              Cauldron::Solution::Composite.new(
                [array_collect, string_asterisk]
              ).to_ruby( variables ).should == 'var0.collect { |var1| var1 * 2 }'
            end

          end

        end

      end

      context %q{with the operators} do 

        let(:variables) { Cauldron::Scope.new(['var0']) }

        it %q{generates the code} do
          Composite.new(
            [Cauldron::VarCollectOperator.new([0]), NumericOperator.new([2], 2) ],
            [Cauldron::VarCollectOperator.new([1]), ToSOperator.new([4])]
          ).to_ruby( variables ).should == %q{
var1 = var0.collect do |var2|
 var2 + 2
 end;
 var3 = var1.collect do |var4|
 var4.to_s 
end
}.strip.gsub(/\n/,'')
        end

      end

      context 'with VarCollect' do

        let(:variables) { Cauldron::Scope.new(['var0']) }

        it %q{
var1 = var0.collect do |var2|
  var2 * 2
end
} do
          Composite.new(
            [Cauldron::VarCollectOperator.new([0]), StringAsteriskOperator.new([2], 2) ]
          ).to_ruby( variables ).should == %q{
var1 = var0.collect do |var2|
 var2 * 2 
end
}.strip.gsub(/\n/,'')
        end

      end      

    end

    describe '#sexp' do

      context 'using initial operator "Array#collect"' do

        let(:collect_operator) { ArrayCollect.new([0]) }

        let(:scope) { Cauldron::Scope.new(['var0']) }

        context 'using second operator "x * 3"' do

          let(:string_multiple) { StringAsteriskOperator.new([1],3) }

          it 'returns "var0.collect {|x| x + 3}"' do
            Composite.new([collect_operator, string_multiple]).sexp(scope).should == [
              :program,
              [:stmts_add,
                [:stmts_new],
                [ :method_add_block, 
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
                      [:params, [[:@ident, "var1"]]]
                    ], 
                    [
                      :stmts_add, 
                      [:stmts_new], 
                      [
                        :binary, 
                        [:vcall, [:@ident, "var1"]], 
                        :*, 
                        [:@int, 3]
                      ]
                    ]
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