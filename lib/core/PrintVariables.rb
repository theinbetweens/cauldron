module PrintVariables

  # 
  def display_name_for(var)

    # Has a name been given to this variable
    unless @variable_names[var.variable_id].nil? then return @variable_names[var.variable_id] end
      
    # Save the name of the new variable  
    var_name = 'var_'+@variable_counter.to_s
    if var.kind_of? MethodParameter
      var_name = 'param_var_'+@variable_counter.to_s
    end
    if var.kind_of? ResponseVariable
      var_name = 'return_var_'+@variable_counter.to_s
    end    
    @variable_counter += 1
    
    # Save the existing name
    @variable_names[var.variable_id] = var_name
    return @variable_names[var.variable_id]    
    
  end
  
end