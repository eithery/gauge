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


			context "when no errors found during inspection" do
				it "should display 'ok' message with the name of the checked database" do
					check_database :ok, 'gauge_db_green'
				end

				it "should display 'ok' messages for all checked databases if more than one passed as arguments" do
					check_databases :ok, good_databases
				end
			end


			context "when errors found during inspection" do
				it "should display 'failed' message with the name of the checked database" do
					check_database :error, 'gauge_db_red'
				end

				it "should display 'failed' messages for all checked databases with errors" do
					should_receive :error, 'gauge_db_yellow'
					should_receive :error, 'gauge_db_red'
					shell.check few_databases
				end

				it "should not display 'failed' messages for all checked databases without errors" do
					should_not_receive :error, 'gauge_db_green'
					shell.check few_databases
				end

				it "should display the total number of found errors" do
					listener.should_receive(:error).with(/Total [\d*] errors found.\n/)
					shell.check 'gauge_db_red'
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
			should_receive(message_type, db_name)
			shell.check db_name
		end


		def check_databases(message_type, databases)
			databases.each do |db_name|
				should_receive(message_type, db_name)
			end
			shell.check databases
		end


		def composed_message(message_type, db_name)
			msg = "Inspecting '#{db_name}' database"
			return msg + " - ok" if message_type == :ok
			return msg + " - failed" if message_type == :error
			msg + "..."
		end


		def should_receive(message_type, db_name)
			listener.should_receive(message_type).with(composed_message(message_type, db_name))
		end


		def should_not_receive(message_type, db_name)
			listener.should_not_receive(message_type).with(composed_message(message_type, db_name))
		end
	end
end
