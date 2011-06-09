class System
  
  def self.reset
    Variable.reset_global_id
    RuntimeMethod.reset_global_id    
  end
  
end