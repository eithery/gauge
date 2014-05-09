# Eithery Lab., 2014.
# Class Gauge::Schema::DatabaseSchema.
# Database schema.
# Contains metadata info defining a database structure.
require 'gauge'

module Gauge
	module Schema
		class DatabaseSchema
			attr_reader :database_name, :tables

			def initialize(database_name, data_root)
				root = File.join(data_root, database_name)
				raise "Metadata for #{database_name} is not defined." unless File.exists?(root)

				@root = root
				@database_name = database_name
				@tables = {}
				Dir["#{@root}/tables/**/*.db.xml"].map do |schema_file|
					table_schema = DataTableSchema.new(schema_file)
					@tables[table_schema.table_name.downcase] = table_schema
				end
			end
		end
	end
end
