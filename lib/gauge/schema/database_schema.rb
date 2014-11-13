# Eithery Lab., 2014.
# Class Gauge::Schema::DatabaseSchema
# Database schema.
# Contains metadata info defining a database structure.
require 'gauge'

module Gauge
	module Schema
		class DatabaseSchema
			attr_reader :database_name, :tables

			def initialize(database_name, options={})
				@database_name = database_name
				@options = options
				@tables = {}

				Dir["#{Repo.metadata_home}/#{sql_name}/**/*.db.xml"].map do |schema_file|
					table_schema = DataTableSchema.new(schema_file)
					@tables[table_schema.to_key] = table_schema
				end
			end


			def sql_name
				@options[:sql_name] || database_name.to_s
			end
		end
	end
end
