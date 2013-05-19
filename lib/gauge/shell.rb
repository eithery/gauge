module Gauge
	class Shell
		attr_accessor :out

		# Creates the new instance of Shell class.
		def initialize(global_options)
			@out = global_options[:out] || STDOUT
		end


		# Performs check operation for the specified database or separate database objects
		# against the predefined schema.
		def check(args)
		end
	end
end
