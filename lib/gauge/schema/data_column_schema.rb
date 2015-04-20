# Eithery Lab., 2015.
# Class Gauge::Schema::DataColumnSchema
# Data column schema.
# Contains metadata info defining a data table column.

require 'gauge'

module Gauge
  module Schema
    class DataColumnSchema
      attr_reader :table

      DEFAULT_VARCHAR_LENGTH = 256
      DEFAULT_CHAR_LENGTH = 1
      DEFAULT_ISO_CODE_LENGTH = 2
      UID = 'abs(convert(bigint,convert(varbinary,newid())))'


      def initialize(*args, &block)
        @column_name = unsplat_name *args
        @options = unsplat_options *args
        instance_eval(&block) if block
        validate_column_type
      end


      def column_name
        return @column_name.to_s unless @column_name.blank?
        col_name = column_name_from_ref || column_name_from_id
        return col_name.to_s unless col_name.blank?

        raise "Data column name is not specified."
      end


      def column_type
        return defined_column_type.to_sym unless defined_column_type.nil?
        return :string if string?
        return :id if contains_ref_id?
        return :bool if bool_by_name?
        return :datetime if datetime_by_name?
        return :date if date_by_name?
        return :id if id? || id_by_name?
        :string
      end


      def sql_type
        return "#{data_type}(#{length})" if [:nvarchar, :nchar].include? data_type
        return "decimal(18,2)" if column_type == :money
        return "decimal(18,4)" if column_type == :percent
        return "varbinary(max)" if column_type == :blob
        return "binary(#{length})" if column_type == :binary
        "#{data_type}"
      end


      def data_type
        return id_data_type if column_type == :id
        type_map[column_type]
      end


      def char_column?
        [:string, :char, :country, :us_state].any? { |t| t == column_type }
      end


      def length
        @options[:len] || default_length
      end


      def allow_null?
        !(identity? || @options[:required] == true)
      end


      def default_value
        default = @options[:default]
        return false if default.nil? && column_type == :bool && !allow_null?
        return UID if default == :uid
        return sql_function(default) if function? default
        default
      end


      def sql_default_value
        return nil if default_value.nil?
        return "'#{default_value}'" if char_column?
        return default_value == true ? 1 : 0 if bool?
        default_value
      end


      def sql_attributes
        "#{sql_type} #{sql_nullability}"
      end


      def to_sym
        column_name.downcase.to_sym
      end


      def id?
        @options[:id] == true
      end


      def business_id?
        @options[:business_id] == true
      end


      def has_index?
        @options.include?(:index) && @options[:index] != false
      end


      def has_unique_constraint?
        @options.include?(:unique) && @options[:unique] != false
      end


      def has_foreign_key?
        contains_ref_id?
      end


      def index
        if has_index?
          options = @options[:index]
          options = {} unless options.respond_to? :[]
          Gauge::DB::Index.new("idx_#{table.to_sym}_#{column_name}", table.table_name, to_sym, options)
        end
      end


      def unique_constraint
        if has_unique_constraint?
          Gauge::DB::Constraints::UniqueConstraint.new("uc_#{table.to_sym}_#{column_name}", table.table_name, to_sym)
        end
      end


      def foreign_key
        if has_foreign_key?
          ref_table_name = "#{ref_table_options[:schema]}.#{ref_table_options[:table]}"
          ref_table = Gauge::Helpers::NameParser.dbo_key_of ref_table_name
          Gauge::DB::Constraints::ForeignKeyConstraint.new("fk_#{table.to_sym}_#{ref_table}_#{to_sym}",
            table.table_name, to_sym, ref_table_name, ref_column)
        end
      end


      def in_table(table_schema)
        @table = table_schema
        self
      end


      def table_schema
        table
      end


      def computed?
        @options.include? :computed
      end


      def bool?
        column_type == :bool
      end

  private

      def column_name_from_ref
        return nil unless contains_ref_id?
        ref_table_options[:table].to_s.singularize + '_id'
      end


      def column_name_from_id
        :id if id?
      end


      def contains_ref_id?
        @options.include?(:ref)
      end


      def identity?
        id? || business_id?
      end


      def bool_by_name?
        column_name.to_s.downcase.start_with?('is', 'has', 'allow')
      end


      def datetime_by_name?
        column_name.to_s.downcase.end_with?('date', '_at')
      end


      def date_by_name?
        column_name.to_s.downcase.end_with?('_on')
      end


      def id_by_name?
        column_name.to_s.downcase.end_with?('id')
      end


      def string?
        @options.include? :len
      end


      def sql_nullability
        allow_null? ? 'null' : 'not null'
      end


      def id_data_type
        return :tinyint if contains_ref_id? && ref_table_options[:schema] == :ref
        !table.nil? && table.reference_table? ? :tinyint : :bigint
      end


      def ref_table_options
        @ref_table_options ||= define_ref_table_options
      end


      def define_ref_table_options
        return {} unless @options.include? :ref
        return @options[:ref] if @options[:ref].kind_of? Hash

        options = {}
        parts = @options[:ref].to_s.split('.')
        options[:schema] = parts.length > 1 ? parts.first.downcase.to_sym : :dbo
        options[:table] = parts.last.downcase.to_sym
        options
      end


      def ref_column
        ref_table_options.include?(:column) ? ref_table_options[:column] : :id
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
          binary: :binary,
          guid: :uniqueidentifier
        }
      end


      def validate_column_type
        raise ArgumentError.new('Invalid column type.') unless defined_column_type.nil? ||
          type_map.include?(defined_column_type.to_sym)
      end


      def unsplat_name(*args)
        return args.first.to_s unless args.first.is_a? Hash
      end


      def unsplat_options(*args)
        args.each { |arg| return arg if arg.is_a? Hash }
        {}
      end


      def default_length
        case column_type
          when :string    then DEFAULT_VARCHAR_LENGTH
          when :char      then DEFAULT_CHAR_LENGTH
          when :us_state  then DEFAULT_ISO_CODE_LENGTH
          when :country   then DEFAULT_ISO_CODE_LENGTH
        end
      end


      def defined_column_type
        @options[:type]
      end


      def function?(default_value)
        return default_value.include? :function if default_value.kind_of? Hash
        false
      end


      def sql_function(default_value)
        current_timestamp?(default_value) ? :current_timestamp : "#{default_value[:function]}()".downcase
      end


      def current_timestamp?(default_value)
        [:current_timestamp, :getdate].include? default_value[:function].downcase
      end
    end
  end
end
