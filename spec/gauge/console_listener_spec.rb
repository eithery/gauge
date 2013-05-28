# Eithery Lab., 2013.
# Defines the spec for Gauge::ConsoleListener class.
require 'spec_helper'

module Gauge
	describe ConsoleListener do
		let (:output) { double('output').as_null_object }
		let (:console) { ConsoleListener.new(:out => output) }
		let (:colors) do
			{
				:red => "\e[31m",
				:green => "\e[32m",
				:yellow => "\e[33m",
				:cyan => "\e[36m"
			}
		end


		describe "#initialize" do
			it "should have STDOUT as a default output" do
				console = ConsoleListener.new
				console.out.should == STDOUT
			end

			it "should have ability to set an external output object" do
				console.out.should == output
			end
		end


		describe "#info" do
			it "should display the specified message in cyan color" do
				output.should_receive(:puts).with(colored_message(:cyan))
				console.info(test_message)
			end
		end


		describe "#warning" do
			it "should display the specified message in yellow color" do
				output.should_receive(:puts).with(colored_message(:yellow))
				console.warning(test_message)
			end
		end


		describe "#error" do
			it "should display the specified message in red color" do
				output.should_receive(:puts).with(colored_message(:red))
				console.error(test_message)
			end
		end


		describe "#ok" do
			it "should display the specified message in green color" do
				output.should_receive(:puts).with(colored_message(:green))
				console.ok(test_message)
			end
		end


private
		def end_color_tag
			"\e[0m"
		end

		def test_message
			"Some text to be displayed to console."
		end

		def colored_message(color)
			colors[color] + test_message + end_color_tag
		end
	end
end
