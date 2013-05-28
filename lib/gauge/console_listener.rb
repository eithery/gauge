# Eithery Lab., 2013.
# Class Gauge::ConsoleListener
# Encapsulates the set of colored output for console-wise operations.
require 'gauge'

module Gauge
	class ConsoleListener
		attr_accessor :out

		# Creates the new instance of Gauge::ConsoleOutput class.
		def initialize(options={})
			@out = options[:out] || STDOUT
		end


		# Displays the informational message to console (in cyan color).
		def info(message)
			@out.puts message.color(:cyan)
		end


		# Displays the warning message to console (in yellow color).
		def warning(message)
			@out.puts message.color(:yellow)
		end


		# Displays the error message to console (in red color).
		def error(message)
			@out.puts message.color(:red)
		end


		# Displays the ok message to console (in green color).
		def ok(message)
			@out.puts message.color(:green)
		end
	end
end
