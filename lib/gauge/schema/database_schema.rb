# Eithery Lab., 2015.
# Class Gauge::Schema::DatabaseSchema
# Database schema.
# Contains metadata info defining a database structure.
require 'gauge'

module Gauge
	module Schema
		class DatabaseSchema
			attr_reader :tables, :views

			def initialize(database_name, options={})
				@database_name = database_name
				@options = options
				@tables = {}
				@views = {}
			end


			def database_schema
				self
			end


			def database_name
				@database_name.to_s
			end


			def sql_name
				@options[:sql_name] || database_name
			end


			def object_name
				'Database'
			end


			def to_sym
				database_name.downcase.to_sym
			end


			def home
				@options[:home]
			end
		end
	end
end
