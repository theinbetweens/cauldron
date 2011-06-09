module Cauldron
  
  module Conversion
    
    def convert_to_example(values)
      CTestCase.new(values[0...(values.length-1)],values.last)
    end
    
    def separate_values(csv)
      csv.split(',').inject([]) {|total,x| total <<  eval(x) }
    end    
    
  end
  
end