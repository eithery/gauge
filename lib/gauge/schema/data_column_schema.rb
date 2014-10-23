# Eithery Lab., 2014.
# Class Gauge::Schema::DataColumnSchema
# Data column schema.
# Contains metadata info defining a data table column.
require 'gauge'

module Gauge
	module Schema
		class DataColumnSchema
			attr_reader :table_name

			def initialize(table_name, column_attributes={})
				@table_name = table_name
				@column_attrs = column_attributes
			end


			def column_name
				@column_attrs[:name] || name_from_ref
			end


			def column_type
				type = @column_attrs[:type]
				return :id if contains_ref_id?
				return type.to_sym unless type.nil?
				return :bool if column_name.downcase.start_with?('is', 'has', 'allow')
				return :datetime if column_name.downcase.end_with?('date', '_at')
				return :date if column_name.downcase.end_with?('_on')
				:string
			end


			def data_type
				type_map[column_type]
			end


			def allow_null?
				!(identity? || @column_attrs[:required])
			end


			def to_key
				column_name.to_sym.downcase
			end


	private

			# Determines the column name based on 'id' or 'ref' attributes.
			def name_from_ref
				raise "Data column name is not specified." unless contains_ref_id?
				ref_name = @column_attrs[:ref]
				ref_name.split('.').last.singularize + '_id'
			end


			# Determines whether the column schema contains ref or id attributes.
			def contains_ref_id?
				@column_attrs.include?(:ref)
			end


			# Determines whether the column is identity or the part of identity.
			def identity?
				@column_attrs.include?(:id) || @column_attrs.include?(:business_id)
			end


			def type_map
				{
					id: :bigint,
					int: :int,
					long: :bigint,
					string: :nvarchar,
					char: :nchar,
					bool: :tinyint,
					byte: :tinyint,
					datetime: :datetime,
					date: :date,
					us_state: :nchar,
					country: :nchar,
					money: :decimal,
					percent: :decimal,
					enum: :tinyint,
					xml: :xml,
					blob: :varbinary,
					binary: :binary
				}
			end
		end
	end
end
