module Cauldron
  
  class TheoryParser
    
    def parse(filepath)
      data = YAML.load_file(filepath)
      Theory.new(data['dependents'],data['action'],data['results'])
    end
   
  end
  
end

# module YAML
# 
  # def YAML.load( io )
    # puts '-----------LOADING YAML file'
    # puts parser.class.to_s
    # yp = parser.load( "dependents: 'adfadsf'" )
  # end
# 
# end