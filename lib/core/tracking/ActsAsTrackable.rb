module ActsAsTrackable
  
  # Returns a tracking statement for the line supplied.  The tracking call 
  # contains the following values.
  # 
  # line                The line the statement occurs on
  # action              The statement written as a literal string - I'm not sure whether or not this is 
  #                     important value or not yet.
  # variables           An array of variables used in the statement - they are saved in the following format
  #                     {'id'=>4,'value'=>'Project Purity'}.  As such the variables only have literal values.
  #                     NOTE: Currently I am only saving the variables in the statement but it might be 
  #                     prudent later to save all the variables available to statement.
  # local_variables     saves an array with the name of all the variables in scope.
  #
  # @param  tracking_method   The runtime method that gets called to retain to tracking information
  # @param  line              The line the tracking call represents (NOTE Currently the line is represented
  #                           by the length of an array to keep scope between methods)
  #                           TODO  I would rather be able to use a single variable.
  # @param  statement         The statement represented by the tracking call this can be nil if it is 
  #                           the start of a method.
  # @param  variables_value   An array of variable values and ids stored in a hash e.g.
  #                           [{'id'=>4,'value'=>'Project Purity'},..]
  #
  def tracking_statement(tracking_method,line,statement_id=nil,variables_value=[],statement=nil) 
    (statement.nil?) ? action = '' : action = statement.to_literal_string
    params = [line.length,statement_id,variables_value,action]
    line.push(1)
    track_statement = Statement.new(DefCall.new(NilVariable.new,tracking_method,*params))
    return track_statement
  end  
  
  # Returns an array of variables abstracted from the variable containers in
  # the format used by the tracking statement.  A variable container includes 
  # a statement, nested statement, block container and runtime method. This is 
  # essentially every variable used in the variable container.
  #
  # The variables are returned in the following format: 
  #   [{id'=>4,'value'=>'Project Purity'},
  #   {id'=>4,'value'=>'Vault 101'},
  #   {id'=>4,'value'=>'Brotherhood of Steel'}]
  #
  # @param  variable_containers   Any number of elements that may contain variables.
  #
  def abstract_variables_for_tracking(*variable_containers)
    results = []
    variable_containers.each do |x|
      # NOTE  This breaks on the ParametersContainer
      #x.each_variable do |y|
      # NOTE  This breaks on statements
      #x.each do |y|
      # NOTE: This breaks histroy
      #x.select {|z| z.kind_of?(Variable)}.each do |y|
      x.select_all {|z| z.kind_of?(Variable)}.each do |y|
        results.push(Hash[
          'id'=>y.variable_id,
          'uniq_id'=>y.uniq_id,
          'value'=>InstanceCallContainer.new(y,Copy.new),
          'abs_id'=>EvalCall.new("#{y.write}.object_id.to_s")
         ])
      end  
    end
    return results
  end
  
end