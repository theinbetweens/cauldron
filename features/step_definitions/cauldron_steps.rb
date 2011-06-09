
When /^I add these "([^"]*)"$/ do |test_cases_statement|
  test_cases = test_cases_statement.split('*')
  test_cases.each do |x|
    @terminal.submit x 
  end
end

Then /^I should receive a runtime method like this "([^"]*)"$/ do |runtime_method_statement|
  runtime_method_statement = runtime_method_statement.gsub('\\n',"\n").gsub('\\t',"\t")
  #@terminal.submit('RUN').should == runtime_method_statement
  @terminal.submit('RUN')
  output.messages.should include(runtime_method_statement)
end


