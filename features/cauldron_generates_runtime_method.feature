Feature: Cauldron generates a runtime method
	I want a runtime method
	That will solve a set of example cases

	Scenario Outline: Generate a solution to a previously solved problem
		Given that the terminal has been created 
		When I add a case with a param <case_1_param> and an expected output of <case_1_output>
		And I add a case with a param <case_2_param> and an expected output of <case_2_output>
		Then I should receive a runtime method like this <runtime_method>

		Scenarios: example with only one parameter
		 | case_1_param | case_1_output | case_2_param | case_2_output | runtime_method                                                                                                        |
		 | "sparky"     | "sparky"      | "kel"        | "kel"         | "def method_0(var_0)\n  return var_0\nend\n"                                                                          |
		 | "fish"       | "animal"      | "carrot"     | "vegetable"   | "def method_0(var_0)\n  if(var_0 == 'fish')\n    return 'animal'\n  end\n  return 'vegetable'\nend\n" |