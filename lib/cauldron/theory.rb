module Cauldron
  
  class Theory
    
    attr_reader :dependents, :action, :results
    
    def initialize(dependents,action,results)
      @dependents, @action, @results = dependents, action, results
    end
    
    def ==(subject)
      return false unless subject.dependents == @dependents
      return false unless subject.action == @action
      subject.results == @results
    end
   
  end
  
end