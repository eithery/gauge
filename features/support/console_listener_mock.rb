# Eithery Lab., 2013.
# Class Gauge::ConsoleListenerMock
# Used as mock object instead of Gauge::ConsoleListener class.
module Gauge
	class ConsoleListenerMock
		attr_reader :messages


		# Creates the new instance of ConsoleListenerMock class.
		def initialize
			@messages = { :cyan => [], :green => [], :red => [], :yellow => [] }
		end


		# Stubs ConsoleListener#info method.
		def info(message)
			messages[:cyan] << message
		end


		# Stubs ConsoleListener#ok method.
		def ok(message)
			messages[:green] << message
		end


		# Stubs ConsoleListener#error method.
		def error(message)
			messages[:red] << message
		end


		# Determines whether the colored message is received.
		def received?(message, color)
			messages[color.to_sym].include?(message)
		end
	end
end
