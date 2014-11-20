# Eithery Lab., 2014.
# Class Gauge::Schema::DataColumnSchema
# Data column schema.
# Contains metadata info defining a data table column.
require 'gauge'

module Gauge
	module Schema
		class DataColumnSchema
			def initialize(column_name, options={}, &block)
				@column_name = column_name
				@options = options
        instance_eval(&block) if block
				validate_column_type
			end


			def column_name
				return @column_name.to_s unless @column_name.blank?
				name_from_ref
			end


			def table_name
				@options[:table].to_s
			end


			def column_type
				type = @options[:type]
				return :id if contains_ref_id?
				return type.to_sym unless type.nil?
				return :bool if bool?
				return :datetime if datetime?
				return :date if date?
				:string
			end


			def data_type
				type_map[column_type]
			end


			def allow_null?
				!(identity? || @options[:required])
			end


			def to_key
				column_name.downcase.to_sym
			end


			def id?
				@options[:id] == true
			end

	private

			def name_from_ref
				raise "Data column name is not specified." unless contains_ref_id?
				ref_name = @options[:ref]
				ref_name.split('.').last.singularize + '_id'
			end


			def contains_ref_id?
				@options.include?(:ref)
			end


			def identity?
				id? || @options.include?(:business_id)
			end


			def bool?
				column_name.to_s.downcase.start_with?('is', 'has', 'allow')
			end


			def datetime?
				column_name.to_s.downcase.end_with?('date', '_at')
			end


			def date?
				column_name.to_s.downcase.end_with?('_on')
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
				col_type = @options[:type]
				raise ArgumentError.new('Invalid column type.') unless col_type.nil? || type_map.include?(col_type.to_sym)
			end
		end
	end
end
