require 'spec_helper'

module Cauldron::Solution
  
  describe 'Composite' do

    describe '#insert_tracking' do

      context %q{
        given a composite:
          def function(params)

          end
        } do

          # code =  """
          #         """

        it %q{
          generates a method:
            def function(params)
              record(0,0,0,local_variables.reject {|foo| foo == :_}.collect { |bar| [bar, eval(bar.to_s)] })
            end
          } do
            Composite.new([]).insert_tracking([]).sexp.should match_code_of( %q{
def function(var0)
  record(0,0,0,local_variables.reject {|foo| foo == :_}.collect { |bar| [bar, eval(bar.to_s)] })
end
})
        end

      end

      context %q{
        given a composite:
          def function(var0)
            var0.collect do |var1|
            end
          end          
      } do

        it %q{
def function(var0)
  var0.collect do |var1|
    record(0,1,1,local_variables.reject {|foo| foo == :_}.collect { |bar| [bar, eval(bar.to_s)] })
  end
  record(1,0,1,local_variables.reject {|foo| foo == :_}.collect { |bar| [bar, eval(bar.to_s)] })
end          
        } do
          Composite.new([]).insert_tracking([]).sexp.should match_code_of( %q{
def function(var0)
  var0.collect do |var1|
    record(0,1,1,local_variables.reject {|foo| foo == :_}.collect { |bar| [bar, eval(bar.to_s)] })
  end
  record(1,0,1,local_variables.reject {|foo| foo == :_}.collect { |bar| [bar, eval(bar.to_s)] })
end
})

        end

      end

    end

    describe '#to_ruby' do

      context 'first line' do

        context 'has operator "Array#collect"' do

          let(:array_collect) { ArrayCollect.new([0]) }

          let(:tree) do
            # Tree::TreeNode.new("ROOT", "Root Content").tap do |root|
            #   root << Tree::TreeNode.new("CHILD1", array_collect)
            #   root << Tree::TreeNode.new("CHILD2", string_asterisk)
            # end
            root = Tree::TreeNode.new("ROOT", "Root Content")
            child = Tree::TreeNode.new("CHILD1", array_collect) 
            grand_child = Tree::TreeNode.new("CHILD2", string_asterisk)
            child << grand_child
            root << child
            root
          end

          context 'has operator "String#*"' do

            let(:string_asterisk) { StringAsteriskOperator.new([1],2) }

            let(:composite) { Composite.new() }

            let(:variables) { Cauldron::Scope.new(['var0']) }

            it 'is "var0.collect { |var1| var1 * 2 }"' do
              Cauldron::Solution::Composite.new(
                tree.children
              ).to_ruby( variables ).should == 'var0.collect { |var1| var1 * 2 }'
            end

          end

        end

      end

      context %q{with the operators} do 

        let(:variables) { Cauldron::Scope.new(['var0']) }

        let(:tree) do
          root_node = Tree::TreeNode.new("ROOT", "Root Content")
          child_node = Tree::TreeNode.new("CHILD1", Cauldron::VarCollectOperator.new([0]) )
          child_node << Tree::TreeNode.new("GRANDCHILD1", NumericOperator.new([2], 2) ) 
          root_node << child_node
          # -- 
          child_node_2 = Tree::TreeNode.new("CHILD2", Cauldron::VarCollectOperator.new([1]) )
          child_node_2 << Tree::TreeNode.new("GRAND-CHILD2", ToSOperator.new([4]) )
          root_node << child_node_2
          root_node
        end

        it %q{generates the code} do
          Composite.new(
            tree.children
            #[Cauldron::VarCollectOperator.new([0]), NumericOperator.new([2], 2) ],
            #[Cauldron::VarCollectOperator.new([1]), ToSOperator.new([4])]
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

        let(:tree) do
          root_node = Tree::TreeNode.new("ROOT", "Root Content")
          child_node = Tree::TreeNode.new("CHILD1", Cauldron::VarCollectOperator.new([0]) )
          child_node_2 = Tree::TreeNode.new("CHILD2", StringAsteriskOperator.new([2], 2) )
          child_node << child_node_2
          root_node << child_node
          root_node
        end

        it %q{
var1 = var0.collect do |var2|
  var2 * 2
end
} do
          Composite.new(
            tree.children
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

          let(:tree) do
            root_node = Tree::TreeNode.new("ROOT", "Root Content")
            child_node = Tree::TreeNode.new("CHILD1", collect_operator )
            child_node_2 = Tree::TreeNode.new("CHILD2", string_multiple )
            child_node << child_node_2
            root_node << child_node
            root_node
          end          

          it 'returns "var0.collect {|x| x + 3}"' do
            Composite.new(tree.children).sexp(scope).should == [
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