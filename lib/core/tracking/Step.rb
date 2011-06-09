# This class represents one of the steps inside a history object.  It will look something 
# like the following:
# 
# {
#   "variables"=>[
#     {"id"=>3, "value"=>"Grim Fandang", "abs_id"=>-606538658, :uniq_id=>3}, 
#     {"id"=>1, "value"=>"Grim Fandango", "abs_id"=>-606538498, :uniq_id=>2}
#   ], 
#   "line"=>1, 
#   "statement_id"=>625, 
#   "action"=>"var='Grim Fandango'.chop"}
#
class Step < Hash
  
  # 
  # @param  variables     TODO  I'm not sure whether this should be the variables that have changed or just
  #                             the ones available on this line.  I think it is only the variables that change value.
  #
  def initialize(line,statement_id,variables,action)
    super()
    self['variables'] = variables
    self['line'] = line
    self['statement_id'] = statement_id
    # TODO  action can proably be dropped - or just replaced with statement.write - I don't
    #       think to_literal_string is useful.
    self['action'] = action
  end
  
  # Returns the data for the variable thats id was specified.
  #
  # @param  id    The id of the variable thats id should be returned
  #  
  def find_data_for_variable(id)
    missing_variable = lambda { raise StandardError.new('Couldn\'t find information on variable '+id.to_s) }
    return self['variables'].detect(missing_variable) {|x| x['id']==id} 
  end
  
  def to_var(id=nil,uniq_id=nil)
    # TODO  I don't know if the the block is used anymore
    return StepVariable.new(self,id) {{:variable_id => id,:uniq_id=>uniq_id}}
  end 
  
  def copy
    # TODO  Don't use Marshal - do it properly
    return Marshal.load(Marshal.dump(self))
  end
  
  def cauldron_method_calls
    return ["['statement_id']"]
  end
  
end