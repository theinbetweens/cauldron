
include Cauldron::Conversion

Given /^that the terminal has been created$/ do
  @terminal = Cauldron::Terminal.new(output)
  @terminal.start
end


When /^I start cauldron$/ do
  @terminal = Cauldron::Terminal.new(output)
  @terminal.start
end

Then /^I should see "([^"]*)"$/ do |message|
   output.messages.should include(message)
end

Then /^then I should see "([^"]*)"$/ do |message|
  output.messages.should include(message)
end

When /^I add the case "([^"]*)"$/ do |test_case|
  @terminal.submit test_case  
end

Given /^that the terminal has been started$/ do
  @terminal = Cauldron::Terminal.new(output)
  @terminal.start  
end

Then /^the case "([^"]*)" should be saved$/ do |test_case|
  @terminal.cases.should include(convert_to_example(separate_values(test_case)))      
end