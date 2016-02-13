require 'spec_helper'

module Cauldron::Solution
  
  describe 'Composite' do

    describe '#clone_solution' do

      

    end

    describe '#end_points' do

      context 'with empty composite' do

        let(:composite) do
          Cauldron::Solution::Composite.new([])
        end

        it 'returns [[0]]' do
          composite.end_points.should include([0])
        end

      end

      context %q{it is: 
        def function(var0)
          var0.chop
        end
      } do

        let(:containing_statement) do
          Cauldron::StatementGenerator.new.build('lion',[:chop]).first.init([0])
        end

        let(:composite) do
          Cauldron::Solution::Composite.new(
            [Tree::TreeNode.new("CHILD1", containing_statement )]
          )
        end        

        it 'returns [[1]]' do
          composite.end_points.should include([1])
        end

        it 'has 1 point' do
          composite.end_points.length.should == 1
        end

      end

      context %q{it is: 
        def function(var0)
          var2 = var0.collect do |var1|
          end
        end
      } do

        let(:containing_statement) do
          Cauldron::StatementGenerator.new.build(['lion','bear'],[:collect]).first.init([0])
        end

        let(:composite) do
          Cauldron::Solution::Composite.new(
            [Tree::TreeNode.new("CHILD1", containing_statement )]
          )
        end  

        it 'has 2 points' do
          composite.end_points.length.should == 2
        end

        it 'has point [[1]]' do
          composite.end_points.should include([1])
        end

        it 'has point [[0,0]]' do
          composite.end_points.should include([0,0])
        end                    

      end

      context %q{it is: 
        def function(var0)
          var2 = var0.collect do |var1|
            var1.chop
          end
        end
      } do

        let(:var1_chop) do
          Cauldron::StatementGenerator.new.build('lion',[:chop]).first.init([0])
        end

        let(:containing_statement) do
          Cauldron::StatementGenerator.new.build(['lion','bear'],[:collect]).first.init([0])
        end

        let(:composite) do
          statement = Tree::TreeNode.new("CHILD1", containing_statement )
          statement << Tree::TreeNode.new("CHILD1", var1_chop )
          Cauldron::Solution::Composite.new(
            [statement]#[Tree::TreeNode.new("CHILD1", containing_statement )]
          )
        end  

        it 'has 2 points' do
          composite.end_points.length.should == 2
        end   

        it 'has point [[1]]' do
          composite.end_points.should include([1])
        end             

        it 'has point [[0,1]]' do
          composite.end_points.should include([0,1])
        end        

      end

    end

    describe '#record' do

      context %q{there is one example "var0 = ['lion','bear']"} do

        let(:example) do 
          Cauldron::Example.new( {arguments: [['lion','bear']], response: 8} )
        end

        context 'composite is "var0 = var1.collect { |var2|}' do

          let(:containing_statement) do
            Cauldron::StatementGenerator.new.build(['lion','bear'],[:collect]).first.init([0])
          end

          let(:composite) do
            Cauldron::Solution::Composite.new(
              [Tree::TreeNode.new("CHILD1", containing_statement )]
            )
          end

          it 'returns a history with 3 log entries' do
            composite.record(example).logs.length.should == 3
          end

        end

      end

    end

    # describe '#tracking_sexp' do

    #   context %q{
    #     given a composite:
    #       def function(var0)
    #         var0.collect do |var1|
    #           var1 * 3 
    #         end
    #       end
    #     } do

    #       let(:array_collect_node) do
    #         node = Tree::TreeNode.new("CHILD1", ArrayCollect.new([0]))
    #         node << Tree::TreeNode.new("CHILD1", StringAsteriskOperator.new([1],3))
    #         node
    #       end

    #       let(:composite) do
    #         Cauldron::Solution::Composite.new(
    #           [array_collect_node]
    #         )
    #       end

    #       let(:scope) do
    #         Cauldron::Scope.new(['var0'])
    #       end

    #       it %q{generates a method:
    #         var0.collect do |var1|
    #           var1 * 3
    #           record(1,1,2,local_variables.reject {|foo| foo == :_}.collect { |bar| [bar, eval(bar.to_s)] })
    #         end
    #         record(1,0,2,local_variables.reject {|foo| foo == :_}.collect { |bar| [bar, eval(bar.to_s)] })
    #       } do
    #         composite.tracking_sexp(scope, Cauldron::Caret.new ).should match_code_of %q{
    #           var0.collect do |var1|
    #             var1 * 3
    #             record(1,1,2,local_variables.reject {|foo| foo == :_}.collect { |bar| [bar, eval(bar.to_s)] })
    #           end
    #           record(1,0,2,local_variables.reject {|foo| foo == :_}.collect { |bar| [bar, eval(bar.to_s)] })              
    #         }
    #       end

    #   end

    # end

    describe '#solution?' do

      let(:problems) do
        Cauldron::ExampleSet.new(
          [
            Cauldron::Example.new({ arguments: [["lion", "bear"]], response: ["bear", "lion"]}),
            Cauldron::Example.new({ arguments: [["foo", "bar"]], response: ["bar", "foo"]})
          ]
        )
      end

      let(:composite) do
        Cauldron::Solution::Composite.new(
          [Tree::TreeNode.new("CHILD1", ArrayCollect.new([0]))]
        )
      end

      it 'is false' do
        composite.solution?(problems).should == false
      end

      context "using valid chop example" do

        let(:examples) do
          Cauldron::ExampleSet.new(
            [
              Cauldron::Example.new({ arguments: ["Sparky"], response: 'Spark'}),
              Cauldron::Example.new({ arguments: ["Kel"], response: 'Ke'})
            ]
          )
        end

        let(:dynamic_operator) do
          Cauldron::StatementGenerator.new.build('string',[:chop]).first.init([0])
        end        

        let(:composite) do
          Cauldron::Solution::Composite.new(
            [Tree::TreeNode.new("CHILD1", dynamic_operator)]
          )
        end

        it 'is true' do
          composite.solution?(examples).should == true
        end

      end      

    end

    describe '#insert_tracking' do

      context %q{
        given a composite:
          def function(params)

          end
        } do

          # code =  """
          #         """
        let(:params) { ['var0'] }

        it %q{
          generates a method:
            def function(params)
              record(0,0,1,[0],local_variables.reject {|foo| foo == :_}.collect { |bar| [bar, eval(bar.to_s)] })
            end
          } do
            Composite.new([]).insert_tracking(params).sexp.should match_code_of( %q{
def function(var0)
  record(0,0,1,[0],local_variables.reject {|foo| foo == :_}.collect { |bar| [bar, eval(bar.to_s)] })
end
})
        end

      end

    end

    describe '#to_ruby' do

      context "hasn't any operators" do

        let(:variables) { Cauldron::Scope.new(['var0']) }

        let(:subject) do
          Cauldron::Solution::Composite.new([])
        end

        it "doesn't raise an error" do
          expect{
            subject.to_ruby( variables )
          }.not_to raise_error
        end

      end

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

    describe '#to_sexp' do

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
            Composite.new(tree.children).to_sexp(scope).should == [
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