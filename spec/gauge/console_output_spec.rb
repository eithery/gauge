# Eithery Lab., 2013.
# Class Gauge::ShellSpec
# Represents the spec for Gauge::ConsoleOutput class.
require 'spec_helper'

module Gauge
	describe ConsoleOutput do
		describe "#initialize" do
			it "should have STDOUT as a default output" do
				console = ConsoleOutput.new
				console.out.should == STDOUT
			end

			it "should have ability to set an external output object" do
				mock = double('output')
				console = ConsoleOutput.new(:out => mock)
				console.out.should == mock
			end
		end


		describe "#info" do
			it "should display the specified message to STDOUT" do
				output = double('output')
				console = ConsoleOutput.new(:out => output)
				text = "Some text to out to console."
				output.should_receive(:puts).with(text)
				console.info(text)
			end

			it "should display the message in cyan color"
		end
	end
end
