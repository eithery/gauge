# Eithery Lab, 2017
# Class Gauge::Schema::DataColumnSchema
# Defines a data column.

require 'gauge'

module Gauge
  module Schema
    class DataColumnSchema
      include Gauge::Helpers::NamesHelper

      DEFAULT_VARCHAR_LENGTH = 255
      DEFAULT_CHAR_LENGTH = 1
      DEFAULT_ISO_CODE_LENGTH = 2
      UID = 'abs(convert(bigint,convert(varbinary,newid())))'


      def initialize(options={})
        @options = options
        verify_column_type
      end


      def table
        @options[:table]
      end

      alias_method :table_schema, :table


      def column_id
        column_name.downcase.to_sym
      end

      alias_method :to_sym, :column_id


      def column_name
        name = @options[:name]
        name = column_name_from_ref || column_name_from_id if name.blank?
        return name.to_s unless name.blank?

        raise ArgumentError, "Data column name is not specified"
      end


      def column_type
        return type.to_sym unless type.nil?
        return :string unless len.nil?
        return :id unless ref.nil?
        return :bool if bool_by_name?
        return :datetime if datetime_by_name?
        return :date if date_by_name?
        return :id if id? || id_by_name?
        :string
      end


      def data_type
        return id_data_type if column_type == :id
        type_map[column_type]
      end


      def sql_type
        return "#{data_type}(#{length})" if [:nvarchar, :nchar].include? data_type
        return "decimal(18,2)" if column_type == :money
        return "decimal(18,4)" if column_type == :percent
        return "varbinary(max)" if column_type == :blob
        return "binary(#{length})" if column_type == :binary
        "#{data_type}"
      end


      def length
        len || default_length
      end


      def char_column?
        [:string, :char, :country, :us_state].any? { |t| t == column_type }
      end


      def allow_null?
        not (identity? || @options[:required] == true)
      end


      def default_value
        default = @options[:default]
        return false if default.nil? && bool? && !allow_null?
        return UID if default == :uid
        return sql_function(default) if function?(default)
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


      def id?
        @options[:id] == true
      end


      def business_id?
        @options[:business_id] == true
      end


      def bool?
        column_type == :bool
      end


      def has_index?
        idx = @options[:index]
        not (idx.nil? || idx == false)
      end


      def index
        if has_index?
          index_options = @options[:index]
          index_options = {} unless index_options.kind_of? Hash
          Gauge::DB::Index.new("idx_#{table.to_sym}_#{column_name}", table: table.table_name,
            columns: column_id, unique: index_options[:unique], clustered: index_options[:clustered])
        end
      end


      def has_unique_constraint?
        unique = @options[:unique]
        not (unique.nil? || unique == false)
      end


      def unique_constraint
        if has_unique_constraint?
          Gauge::DB::Constraints::UniqueConstraint.new("uc_#{table.to_sym}_#{column_name}",
            table: table.table_name, columns: column_id)
        end
      end


      def has_foreign_key?
        !ref.nil?
      end


      def foreign_key
        if has_foreign_key?
          ref_table_name = "#{ref_table_options[:schema]}.#{ref_table_options[:table]}"
          ref_table = dbo_key_of(ref_table_name)
          Gauge::DB::Constraints::ForeignKeyConstraint.new("fk_#{table.to_sym}_#{ref_table}_#{column_id}",
            table: table.table_name, columns: column_id, ref_table: ref_table_name, ref_columns: ref_column)
        end
      end


      def computed?
        !@options[:computed].nil?
      end


  private

      def column_name_from_ref
        return nil if ref.nil?
        ref_table_options[:table].to_s.singularize + '_id'
      end


      def ref_table_options
        @ref_table_options ||= define_ref_table_options
      end


      def define_ref_table_options
        return ref if ref.kind_of? Hash

        ref_options = {}
        parts = ref.to_s.split('.')
        ref_options[:schema] = parts.length > 1 ? parts.first.downcase.to_sym : :dbo
        ref_options[:table] = parts.last.downcase.to_sym
        ref_options
      end


      def column_name_from_id
        :id if id?
      end


      def id_by_name?
        column_name.to_s.downcase.end_with?('id')
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


      def id_data_type
        return :tinyint if !ref.nil? && ref_table_options[:schema] == :ref
        table&.reference_table? ? :tinyint : :bigint
      end


      def identity?
        id? || business_id?
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


      def sql_nullability
        allow_null? ? 'null' : 'not null'
      end


      def ref_column
        ref_table_options.include?(:column) ? ref_table_options[:column] : :id
      end


      def type_map
        @type_map ||= {
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


      def default_length
        case column_type
          when :string    then DEFAULT_VARCHAR_LENGTH
          when :char      then DEFAULT_CHAR_LENGTH
          when :us_state  then DEFAULT_ISO_CODE_LENGTH
          when :country   then DEFAULT_ISO_CODE_LENGTH
        end
      end


      def type
        @options[:type]
      end


      def len
        @options[:len]
      end


      def ref
        @options[:ref]
      end


      def verify_column_type
        raise ArgumentError, 'Invalid column type.' unless type.nil? ||
          type_map.include?(type.to_sym)
      end
    end
  end
end
