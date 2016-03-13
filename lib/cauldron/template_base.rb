module Cauldron

  class TemplateBase

    def self.extend_actualized_composite(x, container, examples, point)
      cloned_container = container.clone_solution
      cloned_container.add_statement_at(x, point)
      cloned_container
      Cauldron::ActualizedComposite.new(cloned_container, examples)
    end    
    
  end

end