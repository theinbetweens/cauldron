Feature: Cauldron generates a runtime method
	I want a runtime method
	That will solve a set of example cases

	Scenario Outline: Generate a solution to a previously solved problem
		Given that the terminal has been created 
		When I add these <cases>
		Then I should receive a runtime method like this <runtime_method>

		Scenarios: example with only one parameter
			|      cases   	   	   				         				|     							runtime_method   						|		demo_num  |
			|  "'sparky','sparky'*'kel','kel'"      			| "def method_3(var_6)\n\treturn var_6\nend\n"  |     1       |
			|	 "'fish','animal'*'carrot','vegatable'"			|	"def method_3(var_0)\n\tif(var_0 == 'fish')\n\t\treturn 'animal'\n\tend\n\treturn 'vegetable'\nend\n" | 2 |	