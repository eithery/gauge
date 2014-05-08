# Eithery Lab., 2014.
# Class Gauge::ConsoleListener
# Encapsulates the set of colored output for console-wise operations.
require 'gauge'

module Gauge
	module ConsoleListener
		# Displays the informational message to console (in cyan color).
		def info(message)
			puts message.color(:cyan)
		end


		# Displays the warning message to console (in yellow color).
		def warning(message)
			puts message.color(:yellow)
		end


		# Displays the error message to console (in red color).
		def error(message)
			puts message.color(:red)
		end


		# Displays the ok message to console (in green color).
		def ok(message)
			puts message.color(:green)
		end


		# Displays the initial message and errors statistics if any.
		def log(message)
			print "#{message} ...".color(:cyan)
			return unless block_given?

			errors = yield
			if errors.empty?
				puts "\r#{message} - ok".color(:green)
			else
				puts "\r#{message} - failed".color(:red).bright
				puts "Errors:".color(:red)
				errors.each { |error| puts "- #{error}".color(:red) }
				puts "Total #{errors.count} errors found.\n".color(:red)
			end
		end
	end
end
