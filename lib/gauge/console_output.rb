# Eithery Lab., 2013.
# Class Gauge::ConsoleOutput
# Encapsulates the set of colored output to console operations.
require 'gauge'

module Gauge
	class ConsoleOutput
		attr_accessor :out

		# Creates the new instance of Gauge::ConsoleOutput class.
		def initialize(options={})
			@out = options[:out] || STDOUT
		end


		# Displays the specified string to console in cyan color.
		def info(string)
			@out.puts string
		end
	end
end
