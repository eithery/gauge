# Eithery Lab., 2014.
# Class Gauge::DB::Database.
# Database.
require 'gauge'

module Gauge
	module DB
		class Database
			# Creates the new instance of Database class.
			def initialize(database_name, connection_options)
				@name = database_name
				@connection = connection_options
			end


			# Validates database schema.
			def validate(database_spec)
			end


			# Validates the data table against the specified spec.
			def validate_table(table_spec)
				errors = []
				Sequel.tinytds(:dataserver => @connection[:server], :database => @name,
					:user => @connection[:user], :password => @connection[:password],
					:default_schema => table_spec.schema ) do |dba|
					dba.test_connection
					return errors << "Missing '#{table_spec.table_name}' data table." unless table_exists?(table_spec, dba)

					table = DataTable.new(table_spec.to_key, dba)
					errors = table.validate(table_spec)
				end
				errors
			end
	end
end
