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
				raise ArgumentError.new('Data table name is not specified.') if table_name.blank?

				@table_name = table_name
				@column_attrs = column_attributes
				validate_column_type
			end


			def column_name
				column_name = @column_attrs[:name] || name_from_ref
				column_name.to_sym
			end


			def column_type
				type = @column_attrs[:type]
				return :id if contains_ref_id?
				return type.to_sym unless type.nil?
				return :bool if column_name.to_s.downcase.start_with?('is', 'has', 'allow')
				return :datetime if column_name.to_s.downcase.end_with?('date', '_at')
				return :date if column_name.to_s.downcase.end_with?('_on')
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
	
			def name_from_ref
				raise "Data column name is not specified." unless contains_ref_id?
				ref_name = @column_attrs[:ref]
				ref_name.split('.').last.singularize + '_id'
			end


			def contains_ref_id?
				@column_attrs.include?(:ref)
			end


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


			def validate_column_type
				col_type = @column_attrs[:type]
				raise ArgumentError.new('Invalid column type.') unless col_type.nil? || type_map.keys.include?(col_type.to_sym)
			end
		end
	end
end
