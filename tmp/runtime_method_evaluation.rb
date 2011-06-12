class RuntimeMethodEvaluation18

	#
	#	This is the method that is being evaluated using 'RuntimeMethodEvaluation18.new.method_0
	#
	def method_0(var_1, var_2, var_3, var_4)
		@var_0 = History.new if @var_0.nil?
		@var_0.push(Step.new(
      var_1,    
      var_2,      
      var_3,         
      var_4
     ))
	end

end