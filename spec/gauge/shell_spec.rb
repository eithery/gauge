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
				check_database :info, 'gauge_db_green'
			end

			it "should display names for all being checked databases if more than one passed as arguments" do
				check_databases :info, few_databases
			end

			context "when no missing data tables" do
				it "should display OK message with the name of database being checked" do
					check_database :ok, 'gauge_db_green'
				end

				it "should display OK messages for all being checked databases if more than one passed as arguments" do
					check_databases :ok, good_databases
				end
			end
		end


private
		def good_databases
			['gauge_db_green', 'gauge_db_green2']
		end

		def few_databases
			['gauge_db_green', 'gauge_db_yellow', 'gauge_db_red']
		end


		def check_database(message_type, db_name)
			listener.should_receive(message_type).with(composed_message(message_type, db_name))
			shell.check db_name
		end


		def check_databases(message_type, databases)
			databases.each do |db_name|
				listener.should_receive(message_type).with(composed_message(message_type, db_name))
			end
			shell.check databases
		end


		def composed_message(message_type, db_name)
			msg = "Inspecting '#{db_name}' database"
			return msg + " - ok" if message_type == :ok
			msg + "..."
		end
	end
end
