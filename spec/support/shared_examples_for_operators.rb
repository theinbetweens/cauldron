RSpec.shared_examples "operator" do

  describe '#to_ruby' do

    it "doesn't raise an error" do
      operator.to_sexp(initial_scope, initial_operators) 
    end
    #to_sexp(scope, operators)
  end

end