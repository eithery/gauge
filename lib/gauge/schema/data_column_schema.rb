# Eithery Lab., 2014.
# Class Gauge::Schema::DataColumnSchema
# Data column schema.
# Contains metadata info defining a data table column.
require 'gauge'

module Gauge
	module Schema
		class DataColumnSchema
			DEFAULT_VARCHAR_LENGTH = 256
			DEFAULT_ISO_CODE_LENGTH = 2

			def initialize(*args, &block)
				@column_name = unsplat_name *args
				@options = unsplat_options *args
        instance_eval(&block) if block
				validate_column_type
			end


			def column_name
				return @column_name.to_s unless @column_name.blank?
				name_from_ref
			end


			def table_name
				@table_name.to_s
			end


			def column_type
				type = @options[:type]
				return type.to_sym unless type.nil?

				return :id if contains_ref_id?
				return :bool if bool?
				return :datetime if datetime?
				return :date if date?
				return :id if id?
				:string
			end


			def data_type
				type_map[column_type]
			end


			def char_column?
				[:string, :char, :country, :us_state].any? { |t| t == column_type }
			end


			def length
				return DataColumnSchema::DEFAULT_ISO_CODE_LENGTH if iso_code_type?
				return @options[:len] || DEFAULT_VARCHAR_LENGTH if char_column?
				nil
			end


			def allow_null?
				!(identity? || @options[:required])
			end


			def default_value
				@options[:default] || default_for_required_bool
			end


			def to_key
				column_name.downcase.to_sym
			end


			def id?
				@options[:id] == true
			end


			def in_table(table_name)
				@table_name = table_name
			end

	private

			def name_from_ref
				raise "Data column name is not specified." unless contains_ref_id?
				ref_name = @options[:ref]
				ref_name.to_s.split('.').last.singularize + '_id'
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
					short: :smallint,
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


			def unsplat_name(*args)
				return args.first.to_s unless args.first.is_a? Hash
			end


			def unsplat_options(*args)
				args.each { |arg| return arg if arg.is_a? Hash }
				{}
			end


			def iso_code_type?
				column_type == :us_state || column_type == :country
			end


			def default_for_required_bool
				return false if column_type == :bool && !allow_null?
			end
		end
	end
end
