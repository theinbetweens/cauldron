class TheoryCollection
  
  attr_reader :theories
  
  def initialize(theories)
    @theories = theories
  end
  
  def each_with_result_structure(structure)
    @theories.each do |t|
      t.results.each do |r|
        if r.same_structure?(structure)
          yield t, r
        end
      end
    end
  end
  
  def each_with_dependent_structure(structure)
    @theories.each do |t|
      t.dependents.each do |d|
        if d.same_structure?(structure)
          yield t, d
        end
      end
    end    
  end
  
  # Returns the number of theories that have dependents 
  # or results that match the structure supplied.
  # 
  # @param    approach      Either :dependents or :results
  #
  def same_structure_count(structure,approach)
    @theories.inject(0) do |total,theory|
      total += theory.send(approach).count {|x| x.same_structure?(structure)}
    end
  end
  
  # Returns all the dependents within the theories
  #
  def dependents
    @theories.inject([]) {|total,theory| total += theory.dependents }
  end
  
  def results
    @theories.inject([]) {|total,theory| total += theory.results }
  end
  
  def actions
    @theories.select {|x| x.action != nil}.inject([]) {|total,theory| total << theory.action }
  end
  
  def components
    return dependents+results
  end
  
  # Returns an array of all the uniq theory variables used.
  def theory_variables
    return @theories.inject([]) {|total,x| total += x.all_theory_variables}.uniq
  end
end