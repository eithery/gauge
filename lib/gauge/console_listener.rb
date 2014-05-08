# Eithery Lab., 2014.
# Class Gauge::ConsoleListener
# Encapsulates the set of colored output for console-wise operations.
require 'gauge'

module Gauge
	class ConsoleListener
		attr_accessor :out

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


		# Displays the initial message and errors statistics if any.
		def log(message)
			@out.print "#{message} ...".color(:cyan)
			return unless block_given?

			errors = yield
			if errors.empty?
				@out.puts "\r#{message} - ok".color(:green)
			else
				@out.puts "\r#{message} - failed".color(:red).bright
				@out.puts "Errors:".color(:red)
				errors.each { |error| @out.puts "- #{error}".color(:red) }
				@out.puts "Total #{errors.count} errors found.\n".color(:red)
			end
		end
	end
end
