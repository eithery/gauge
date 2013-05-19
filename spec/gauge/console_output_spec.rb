# Eithery Lab., 2013.
# Defines the spec for Gauge::ConsoleOutput class.
require 'spec_helper'

module Gauge
	describe ConsoleOutput do
		let (:output) { double('output').as_null_object }
		let (:console) { ConsoleOutput.new(:out => output) }

		describe "#initialize" do
			it "should have STDOUT as a default output" do
				default_console = ConsoleOutput.new
				default_console.out.should == STDOUT
			end

			it "should have ability to set an external output object" do
				console.out.should == output
			end
		end


		describe "#info" do
			it "should display the specified message to STDOUT" do
				text = "Some text to out to console."
				output.should_receive(:puts).with(text)
				console.info(text)
			end
		end
	end
end
