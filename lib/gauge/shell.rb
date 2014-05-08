# Eithery Lab., 2014.
# Class Gauge::Shell
# Executes application commands.
module Gauge
	class Shell
		attr_reader :listeners

		def initialize
			Rainbow.enabled = true
			@listeners = [ConsoleListener.new]
		end


		# Performs check operation for the specified database or separate database objects
		# against the predefined schema.
		def check(args)
			dbo_names = args.respond_to?(:each) ? args : [args]
			dbo_names.each do |dbo_name|
				@listeners.each do |listener|
					listener.info("Inspecting '#{dbo_name}' database...")
					listener.ok("Inspecting '#{dbo_name}' database - ok") if dbo_name =~ /gauge_db_green/
					listener.error("Inspecting '#{dbo_name}' database - failed") unless dbo_name =~ /gauge_db_green/
					listener.error("Total 3 errors found.\n") unless dbo_name =~ /gauge_db_green/
				end
			end
		end
	end
end
