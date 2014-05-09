# Eithery Lab., 2014.
# Class Gauge::Schema::DataColumnSchema.
# Data column schema.
# Contains metadata info defining a data table column.
require 'gauge'

module Gauge
	module Schema
		class DataColumnSchema
			def initialize(column_attributes)
				@column_attrs = column_attributes
			end


			# Data column name.
			def column_name
				@column_attrs[:name] || name_from_ref
			end


			# Column type.
			def column_type
				type = @column_attrs[:type]
				return type.to_sym unless type.nil?
				return :bool if column_name.downcase.start_with?('is', 'has')
				return :id if contains_ref_id?
				:string
			end


			def data_type
				type_map[column_type]
			end


			# Determines whether the data column allows NULLs.
			def allow_null?
				!(identity? || @column_attrs[:required])
			end


			# Converts a column name into the symbol in downcase to be used as key.
			def to_key
				column_name.to_sym.downcase
			end


		private
			# Determines the column name based on 'id' or 'ref' attributes.
			def name_from_ref
				raise "Data column name is not specified." unless contains_ref_id?
				ref_name = @column_attrs[:ref]
				ref_name.nil? ? 'id' : ref_name.split('.').last.singularize + '_id'
			end


			# Determines whether the column schema contains ref or id attributes.
			def contains_ref_id?
				@column_attrs.include?(:ref) || @column_attrs.include?(:id)
			end


			# Determines whether the column is identity or the part of identity.
			def identity?
				@column_attrs.include?(:id) || @column_attrs.include?(:business_id)
			end


			def type_map
				{
					:string => 'nvarchar',
					:id => 'bigint',
					:bool => 'tinyint',
					:int => 'int',
					:byte => 'tinyint',
					:datetime => 'datetime',
					:date => 'datetime',
					:us_state => 'nchar',
					:country => 'nchar',
					:money => 'decimal',
					:enum => 'tinyint',
					:long => 'bigint',
					:xml => 'xml'
				}
			end
		end
	end
end
