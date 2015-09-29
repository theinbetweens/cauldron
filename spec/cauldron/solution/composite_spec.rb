require 'spec_helper'

module Cauldron::Solution
  
  describe 'Composite' do

    describe '#sexp' do

      context 'using initial operator "Array#collect"' do

        let(:collect_operator) { ArrayCollect.new }

        context 'using second operator "x * 3"' do

          let(:string_multiple) { StringAsteriskOperator.new(3) }

          it 'returns "var0.collect {|x| x + 3}"' do
            Composite.new(collect_operator, string_multiple).sexp.should == [
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