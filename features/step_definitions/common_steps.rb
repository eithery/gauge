Given(/^gauge application$/) do
end


When(/^I run "(.*?)" command with "(.*?)" argument$/) do |command, arg|
	@shell = Gauge::Shell.new(:out => OutputMock.new)
	@shell.check(arg) if command == 'check'
end


Then(/^the app should display "(.*?)" in "(.*?)"$/) do |message, color|
	output = @shell.out
	output.receive_message?(message, color).should be_true
end
