# Eithery Lab., 2013.
# Class Gauge::Shell
# Executes application commands.
module Gauge
	class Shell
		attr_accessor :listeners

		# Creates the new instance of Shell class.
		def initialize
			@listeners = [ConsoleListener.new]
		end


		# Performs check operation for the specified database or separate database objects
		# against the predefined schema.
		def check(args)
			dbo_names = args.respond_to?(:each) ? args : [args]
			dbo_names.each do |dbo_name|
				@listeners.each do |listener|
					listener.info("Inspecting '#{dbo_name}' database...")
				end
			end
		end
	end
end
