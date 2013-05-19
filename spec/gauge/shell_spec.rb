# Eithery Lab., 2013.
# Class Gauge::ShellSpec
# Represents the spec for Gauge::Shell class.
require 'spec_helper'

module Gauge
	describe Shell do
		let (:output) { double('output').as_null_object }
		let (:shell) { Shell.new(:out => output) }

		describe "#initialize" do
			it "should have STDOUT as default output" do
				default_shell = Shell.new
				default_shell.out.class.should == ConsoleOutput
			end

			it "should have ability to set an external output object" do
				shell.out.should == output
			end
		end


		describe "#check" do
			it "should display the name of database being checked" do
				output.should_receive(:info).with("Inspecting 'gauge_db_green' database...")
				shell.check ['gauge_db_green']
			end

			it "should display names for all being checked databases if more than one passed as arguments" do
				databases = ['gauge_db_green', 'gauge_db_yellow', 'gauge_db_red']
				databases.each do |db_name|
					output.should_receive(:info).with("Inspecting '#{db_name}' database...")
				end
				shell.check databases
			end
		end
	end
end
