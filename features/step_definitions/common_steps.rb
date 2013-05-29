Given(/^gauge application$/) do
end


When(/^I run "(.*?)" command passing "(.*?)" argument as the database name$/) do |command, arg|
	@shell = Gauge::Shell.new
	@listener = Gauge::ConsoleListenerMock.new

	@shell.listeners.clear
	@shell.listeners << @listener
	@shell.check(arg) if command == 'check'
end


Then(/^the app should display "(.*?)" in "(.*?)" color$/) do |message, color|
	@listener.should be_received(message, color)
end
