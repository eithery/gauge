# Eithery Lab., 2014.
# Class Gauge::Schema::DatabaseSchema
# Database schema.
# Contains metadata info defining a database structure.
require 'gauge'

module Gauge
	module Schema
		class DatabaseSchema
			attr_reader :database_name, :tables

			def initialize(database_name, options)
#				db_definition_file = File.join(data_root, 'databases.rb')
#				raise "Metadata for '#{database}' database is not defined." unless File.exists?(db_definition_file)

#				require db_definition_file

				@database_name = database_name
				@tables = {}

#				Dir["#{data_root}/#{database_name}/**/*.db.xml"].map do |schema_file|
#					table_schema = DataTableSchema.new(schema_file)
#					@tables[table_schema.to_key] = table_schema
#				end
			end
		end
	end
end
