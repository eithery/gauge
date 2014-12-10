# Eithery Lab., 2014.
# Class Gauge::Validators::MissingColumnValidator
# Performs check for missing data column.
require 'gauge'

module Gauge
  module Validators
    class MissingColumnValidator < Validators::Base

      validate do |column_schema, dba|
        result = true
        unless dba.column_exists? column_schema
          missing_column column_schema.column_name
          result = false

          build_sql(column_schema.table_name, "add_#{column_schema.column_name}_column") do
            "alter table #{column_schema.table_name}\n" +
            "add [#{column_schema.column_name}] #{column_attributes(column_schema)};\n" +
            "go\n"
          end
        end
        result
      end

  private

      def missing_column(column_name)
        errors << "Data column '<b>#{column_name}</b>' does <b>NOT</b> exist."
      end


      def column_attributes(column)
        attrs = "#{column_type(column)} #{nullability(column)}"
        attrs += default_value(column) unless column.default_value.nil?
        attrs
      end


      def column_type(column)
        type = [column.data_type.to_s]
        type << "(#{column.length})" if [:nvarchar, :nchar].include? column.data_type
        type << "(18,2)" if column.column_type == :money
        type.join
      end


      def nullability(column)
        column.allow_null? ? 'null' : 'not null'
      end


      def default_value(column)
      end
    end
  end
end
