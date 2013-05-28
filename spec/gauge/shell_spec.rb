# Eithery Lab., 2013.
# Defines the spec for Gauge::Shell class.
require 'spec_helper'

module Gauge
	describe Shell do
		let (:listener) { double('listener').as_null_object }
		let (:shell) do
			shell = Shell.new
			shell.listeners.clear
			shell.listeners << listener
			shell
		end


		describe "#initialize" do
			it "should have ConsoleListener as default listener" do
				shell = Shell.new
				shell.listeners.should have(1).listener
				shell.listeners.first.should be_a(ConsoleListener)
			end

			it "should have ability to set additional listener" do
				shell = Shell.new
				shell.listeners << listener
				shell.listeners.should have(2).listeners
				shell.listeners.last.should == listener
			end

			it "should have ability to clear the array of listeners" do
				shell = Shell.new
				shell.listeners.clear
				shell.listeners.should be_empty
			end
		end


		describe "#check" do
			it "should display the name of database being checked" do
				listener.should_receive(:info).with("Inspecting 'gauge_db_green' database...")
				shell.check 'gauge_db_green'
			end

			it "should display names for all being checked databases if more than one passed as arguments" do
				databases = ['gauge_db_green', 'gauge_db_yellow', 'gauge_db_red']
				databases.each do |db_name|
					listener.should_receive(:info).with("Inspecting '#{db_name}' database...")
				end
				shell.check databases
			end
		end
	end
end
