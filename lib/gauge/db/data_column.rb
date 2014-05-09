# Eithery Lab., 2014.
# Class Gauge::DB::DataColumn.
# Data column.
# Encapsulates data column properties.
require 'gauge'

module Gauge
	module DB
		class DataColumn
			attr_reader :name
			private :name

			# Creates the new instance of DataColumn class.
			def initialize(column_name, options)
				@name = column_name
				@options = options
			end


			# Performs validation operation for the data column against the spec.
			def validate(column_spec)
				errors = []
				if column_spec.allow_null? != allow_null?
					should_be = column_spec.allow_null? ? 'NULL' : 'NOT NULL'
					errors << "Column '#{name}' must be defined as #{should_be}."
				end
				if column_spec.data_type != data_type
					errors << "Column '#{name}' is '#{data_type}' but it must be '#{column_spec.data_type}'."
				end
				errors
			end


		private
			# Determines whether data column allows NULL value.
			def allow_null?
				@options[:allow_null]
			end


			# Column data type.
			def data_type
				@options[:db_type]
			end
		end
	end
end
