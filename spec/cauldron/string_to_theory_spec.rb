require 'spec_helper'

# http://blog.jayfields.com/2006/12/ruby-multiline-strings-here-doc-or.html

module Cauldron
  
  describe StringToTheory do 
    
    describe '.run' do
      it 'can generate the theory statment "var8 = 9"' do
        StringToTheory.run('var8 = 9').write.should == 'var8 = 9'
      end
      it %q{can generate the theory statment "var5 = 'enterprise'"} do
        StringToTheory.run("var5 = 'enterprise'").write.should == "var5 = 'enterprise'"
        StringToTheory.run("var5 = 'enterprise'").write.should_not == "var_5 = 'enterprise'"
        StringToTheory.run("var5 = 'enterprise'").should be_a_kind_of(TheoryStatement)
      end
      it 'can generate the theory statment "var1.kind_of?(RuntimeMethod)"' do
        StringToTheory.run("var1.kind_of?(RuntimeMethod)").write.should == 'var1.kind_of?(RuntimeMethod)'
        StringToTheory.run("var1.kind_of?(RuntimeMethod)").should be_a_kind_of(TheoryStatement)
      end      
    end
    
    describe '.create_dependent' do
      it 'can generate a dependent from the following string "var1.kind_of?(RuntimeMethod)"' do
        StringToTheory.create_dependent('var1.kind_of?(RuntimeMethod)').should be_a_kind_of(TheoryDependent)
      end
      it 'can generate a dependent from "var1.kind_of?(RuntimeMethod)" that retains the same structure' do
        StringToTheory.create_dependent('var2.kind_of?(RuntimeMethod)').write.should == %q{
if(var2.kind_of?(RuntimeMethod))
  return true
end
        }.strip
      end
      # TODO  It would be nice to have the cucumber """ notation here - heredoc doesn't seem to strip the indent
      it 'can generate a matching dependent from "var2.length == 2"' do
        StringToTheory.create_dependent('var2.length == 2').write.should == %q{
if(var2.length == 2)
  return true
end        
      }.strip
      end
    end
    
    describe '.create_result' do
      it 'can convert "var1.kind_of?(RuntimeMethod)" into a theory result' do
        result_string = %q{
if(var1.kind_of?(RuntimeMethod))
  return true
end        
        }.strip
        StringToTheory.create_result('var1.kind_of?(RuntimeMethod)').write.should == result_string 
      end      
    end
    
    describe '.create_action' do
      it 'can create the action "return var3[var4][:output]"' do
        written_action = %q{
          <runtime_method>.add_statement_at(Statement.new(Return.new, var3[var4][:output]),var1.first.statement_id)          
        }.strip
        StringToTheory.create_action('return x', 'var1.first.statement_id',{'x' => 'var3[var4][:output]'}).write.should == written_action
      end
      
      it 'can create the action "if x == y "' do 
        written_action = %q{
         <runtime_method>.add_statement_at(OpenStatement.new(TheoryStatement.new(If.new, Container.new(var1.params[var3], Equivalent.new, var2[var4][:params][var5]))),var1.statement_id)           
        }.strip
        StringToTheory.create_action(
          'if x == y','var1.statement_id',{'x' => 'var1.params[var3]', 'y' => 'var2[var4][:params][var5]'}
        ).write.should == written_action
      end
      
    end

  end

end