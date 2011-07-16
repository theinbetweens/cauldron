
# When /^I add these "([^"]*)"$/ do |test_cases_statement|
  # test_cases = test_cases_statement.split('*')
  # test_cases.each do |x|
    # @terminal.submit x 
  # end
# end

When /^I add a case with a param "([^"]*)" and an expected output of "([^"]*)"$/ do |param, output|
  #@terminal.submit("'"+param+,"'+output+'"')  
  @terminal.submit("'#{param}','#{output}'")
end

Then /^I should receive a runtime method like this "([^"]*)"$/ do |runtime_method_statement|
  runtime_method_statement = runtime_method_statement.gsub('\\n',"\n").gsub('\\t',"\t")
  @terminal.submit('RUN')
  output.messages.should include(runtime_method_statement)
end


