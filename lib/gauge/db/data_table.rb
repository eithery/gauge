# Eithery Lab., 2014.
# Class Gauge::DB::DataTable.
# Data table.
# Encapsulates data table schema.
require 'gauge'

module Gauge
	module DB
		class DataTable
			attr_reader :columns

			# Creates the new instance of DataTable class.
			def initialize(table_name, dba)
				@dba = dba
				@columns = {}
				dba.schema(table_name).each do |item|
					column_key, options = item
					@columns[column_key] = DataColumn.new(column_key, options)
				end
			end


			# Validates data table schema against the specified spec.
			def validate(table_spec)
				errors = []
				table_spec.columns.each do |col|
					if column_exists?(col)
						errors += self[col].validate(col)
					else
						errors << "Missing '#{col.column_name}' data column."
					end
				end
				errors
			end


		private
			# Determines whether the column exists in the data table.
			def column_exists?(column_spec)
				@columns.has_key?(column_spec.to_key)
			end


			# Retrieves DataColumn instance for the specified data column spec.
			def [](column_spec)
				@columns[column_spec.to_key]
			end
		end
	end
end
