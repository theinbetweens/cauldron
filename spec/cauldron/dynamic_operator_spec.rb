require 'spec_helper'

module Cauldron
  
  describe DynamicOperator do

    describe '#extend_validation' do

      # PENDING - it should add more tracking as sexp
    end

    describe '#branch?' do

      context 'var0.chop' do

        let(:dynamic_operator) do
          StatementGenerator.new.default_template('string',:chop).new([0])
        end

        it 'is false' do
          dynamic_operator.branch?.should == false
        end

      end

      context 'var1 = var0.collect { |var2| var2}' do

        let(:dynamic_operator) do
          StatementGenerator.new.default_template(
            ['00sjack00','RowIAGE', 'iNathalie'],
            :collect
          ).new([0])
        end

        it 'is true' do
          dynamic_operator.branch?.should == true
        end

      end

    end

    describe '#to_sexp' do

      context 'var1 = var0.collect { |var2| var2}' do

        let(:dynamic_operator) do
          StatementGenerator.new.default_template(
            ['00sjack00','RowIAGE', 'iNathalie'],
            :collect
          ).new([0])
        end

        let(:scope) { Cauldron::Scope.new(['var0']) }

        it 'is var1 = var0.collect { |var2| var2}' do
          dynamic_operator.to_sexp(scope,[]).should match_code_of(%q{
                                                                  var1 = var0.collect do |var2|
                                                                  end
                                                                }
          )
        end

        context 'scope contains two parameters' do

          let(:scope) { Cauldron::Scope.new(['var0', 'var1']) }

          it 'is var1 = var0.collect { |var2| var2}' do
            dynamic_operator.to_sexp(scope,[]).should match_code_of(%q{
                                                                    var2 = var0.collect do |var3|
                                                                      
                                                                    end
                                                                  }
            )
          end          

        end

      end

    end

    describe '#realizable?' do

      context 'var1 = var0.collect { |var2| var2}' do

        let(:dynamic_operator) do
          StatementGenerator.new.default_template(['a','b','c'],:collect).new([0])
        end

        context "when var0 only value is ['a','b','c']" do

          let(:histories) do
            Cauldron::Histories.new([Cauldron::History.new([{var0: ['a','b','c']}])])
          end        

          it 'is true' do
            dynamic_operator.realizable?(histories, [0,0]).should == true
          end

        end

        context 'when var0 only value "string"' do

          let(:histories) do
            Cauldron::Histories.new([Cauldron::History.new([{var0: "string"}])])
          end          

          it 'is false' do
            dynamic_operator.realizable?(histories, [0,0]).should == false
          end

        end

        context %q{adding statement inside: 
                    var1 = var0.collect do |var2| 
                    end
          } do

            let(:containing_statement) do
              StatementGenerator.new.default_template(['a','b','c'],:collect).new([0])
            end

            let(:examples) do
              Cauldron::ExampleSet.new(
                [Cauldron::Example.new({ arguments: [["lion", "bear"]], response: ["bear", "lion"]})]
              )
            end

            let(:composite) do
              Cauldron::Solution::Composite.new(
                [Tree::TreeNode.new("CHILD1", containing_statement )]
              )
            end

            let(:histories) do
              Cauldron::ActualizedComposite.new(composite,examples).histories
            end            

            context 'adding statement "var3 = var2.collect { |var4| var4}"' do

              let(:dynamic_operator) do
                StatementGenerator.new.default_template(['a','b','c'],:collect).new([2])
              end              

              it 'is false' do
                dynamic_operator.realizable?(histories, [0,1]).should == false
              end           

            end

            context 'inserting statement "var3 = var1.collect { |var4| var4}"' do

              let(:dynamic_operator) do
                StatementGenerator.new.default_template(['a','b','c'],:collect).new([1])
              end              

              it 'is false' do
                dynamic_operator.realizable?(histories, [0,1]).should == false
              end           

            end            

        end

      end

      context 'var0.chop' do

        let(:dynamic_operator) do
          StatementGenerator.new.default_template('string',:chop).new([0])
        end

        let(:composite) do
          Cauldron::Solution::Composite.new(
            [ Tree::TreeNode.new("CHILD1", dynamic_operator ) ]
          )
        end

        describe '#context_instances' do

          context %q{describe using [:var0 => 'asdas', :var1 => '3232']} do

            let(:dynamic_operator_class) { StatementGenerator.new.default_template('string',:chop) }

            it 'returns 2 instances' do
              expect(dynamic_operator_class.context_instances(
                [
                  {:var0=>["Sparky", "Kels"], :var1=>nil, :line=>0, :depth=>1, :total_line=>3, :point=>[0, 0]},
                ]
              ).length).to eql(2)
            end

          end

        end

        describe '#context_realizable?' do

          let(:dynamic_operator_class) { StatementGenerator.new.default_template('string',:chop) }

          context 'using var 0' do

            context 'with context "{:var0=>["Sparky", "Kels"], :point=>[0, 0]}"' do

              let(:context) do
                {:var0=>["Sparky", "Kels"], :point=>[0, 0]}
              end              

              it 'returns false' do
                expect(dynamic_operator_class.new([0]).context_realizable?(context)).to be false
              end

            end

          end

          context 'var2 is "Sparky"' do

            let(:context) do
              {:var2=>"Sparky", :var0=>["Sparky", "Kels"], :var1=>nil, :line=>0, :depth=>1, :total_line=>2, :point=>[0, 0]}
            end

            context 'using the index "2"' do

              it 'returns true' do
                expect(dynamic_operator_class.new([2]).context_realizable?(context)).to be true
              end  

            end

            context 'using the index "0"' do

              it 'returns true' do
                expect(dynamic_operator_class.new([0]).context_realizable?(context)).to be false
              end  

            end            

          end          

        end

        context %q{adding statement inside: 
                    var1 = var0.collect do |var2| 
                    end
          } do

            let(:containing_statement) do
              StatementGenerator.new.default_template(['lion','bear'],:collect).new([0])
            end

            context %q{var0 is ["lion", "bear"]} do

              let(:examples) do
                Cauldron::ExampleSet.new(
                  [Cauldron::Example.new({ arguments: [["lion", "bear"]], response: ["bear", "lion"]})]
                )
              end

              let(:examples) do
                Cauldron::ExampleSet.new(
                  [Cauldron::Example.new({ arguments: [["lion", "bear"]], response: ["bear", "lion"]})]
                )
              end

              let(:composite) do
                Cauldron::Solution::Composite.new(
                  [Tree::TreeNode.new("CHILD1", containing_statement )]
                )
              end

              let(:histories) do
                Cauldron::ActualizedComposite.new(composite,examples).histories
              end          

            end

        end        

        describe 'using incompatible variable' do

          context 'when var0 is 8' do

            let(:histories) do
              Cauldron::Histories.new([Cauldron::History.new([{var0: 8}])])
            end

            it 'saves the failed example' do
              expect{
                dynamic_operator.realizable?(histories, [0,0])
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
            dynamic_operator.should_not be_realizable(histories, [0,0])
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
            dynamic_operator.should be_realizable(histories,[0,0])
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
              dynamic_operator.should be_realizable(histories,[0,0])
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