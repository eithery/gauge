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
				:light_red => "\e[31m\e[1m",
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
				should_display test_message, :cyan
				console.info(test_message)
			end
		end


		describe "#warning" do
			it "should display the specified message in yellow color" do
				should_display test_message, :yellow
				console.warning(test_message)
			end
		end


		describe "#error" do
			it "should display the specified message in red color" do
				should_display test_message, :red
				console.error(test_message)
			end
		end


		describe "#ok" do
			it "should display the specified message in green color" do
				should_display test_message, :green
				console.ok(test_message)
			end
		end


		describe "#log" do
			it "should display the initial message in cyan color" do
				output.should_receive(:print).with(colored "#{test_message} ...", :cyan)
				console.log(test_message)
			end


			context "if no error detected" do
				it "should add the suffix 'ok' to the end of the initial message in green color" do
					should_display "\r#{test_message} - ok", :green
					console.log(test_message) { mock_with_no_errors }
				end
			end


			context "if errors detected" do
				it "should add the suffix 'failed' to the end of the initial message in bright red color" do
					should_display "\r#{test_message} - failed", :light_red
					console.log(test_message) { mock_with_four_errors }
				end


				it "should display each error message in red color" do
					should_display "Errors:", :red
					mock_with_four_errors.each do |error|
						should_display "- #{error}", :red
					end
					console.log(test_message) { mock_with_four_errors }
				end


				it "should display the total number of found errors in red color" do
					should_display "Total 4 errors found.\n", :red
					console.log(test_message) { mock_with_four_errors }
				end
			end
		end


private
		def end_color_tag
			"\e[0m"
		end

		def test_message
			"Inspecting 'PackageMe' database"
		end

		def colored_message(color)
			colored(test_message, color)
		end

		def colored(text, color)
			colors[color] + text + end_color_tag
		end

		def mock_with_no_errors
			[]
		end

		def mock_with_four_errors
			[
				'Missing [test].[customers] data table.',
				'Missing [id] data column.',
				'Invalid type of [name] data column.',
				'Missing [test].[accounts] data table.'
			]
		end

		def should_display(message, color)
				output.should_receive(:puts).with(colored message, color)
		end
	end
end
