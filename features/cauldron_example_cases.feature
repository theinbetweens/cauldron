Feature: User enters example cases
	The user enters a number of example cases that get saved to be ran later

	Scenario Outline: add test cases
		Given that the terminal has been started
		When I add the case "<case>"
		Then the case "<case>" should be saved 
		
		Scenarios: single paramerter cases
			| 					case 						|
			| 'sparky', 'spark'					|
			| 'kel', 'kel'					 		|
			