RSpec.shared_examples "leaf_operator" do

  describe '#branch?' do

    it 'is false' do
      leaf_operator.branch?.should == false
    end
    
  end

  describe '.uses_block?' do 

    it 'is false' do
      leaf_operator.class.uses_block?.should == false
    end
    
  end

  # it "is empty when first created" do
  #   expect(described_class.new).to be_empty
  # end
end
