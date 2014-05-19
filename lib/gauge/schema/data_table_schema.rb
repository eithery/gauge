# Eithery Lab., 2014.
# Class Gauge::Schema::DataTableSchema.
# Data table schema.
# Contains metadata info defining a data table structure.
require 'gauge'

module Gauge
  module Schema
    class DataTableSchema
      attr_reader :local_name, :sql_schema, :columns
      private :local_name

      def initialize(schema_file)
        raise "Metadata file '#{schema_file}' not found." unless File.exists?(schema_file)
        @schema_file = schema_file
        @columns = []
        File.open(schema_file, 'r') { |file| parse_xml REXML::Document.new(file) }
      end


      # Returns the database name containing the table.
      def database_name
        parts = @schema_file.split('/')
        parts[parts.find_index('tables') - 1]
      end


      # Returns the full table name.
      def table_name
        @sql_schema.nil? ? @local_name : @sql_schema + '.' + @local_name
      end


      def to_key
        local_name.to_sym.downcase
      end


private
      def parse_xml(xml_doc)
        @xml = xml_doc
        @local_name = xml_doc.root.attributes['name']
        @sql_schema = xml_doc.root.attributes['schema']
        @columns << DataColumnSchema.new(@local_name, name: 'id', type: 'long', required: true) unless has_id?
        xml_doc.root.each_element('/table/columns/col') do |col|
          column_attributes = {}
          col.attributes.each { |name, value| column_attributes[name.to_sym] = value }
          @columns << DataColumnSchema.new(@local_name, column_attributes)
        end
        if has_timestamps?
          @columns << DataColumnSchema.new(@local_name, name: 'created', type: 'datetime', required: true)
          @columns << DataColumnSchema.new(@local_name, name: created_by_column, required: true)
          @columns << DataColumnSchema.new(@local_name, name: 'modified', type: 'datetime', required: true)
          @columns << DataColumnSchema.new(@local_name, name: modified_by_column, required: true)
          @columns << DataColumnSchema.new(@local_name, name: 'version', type: 'long', required: true)
        end
      end


      def has_id?
        !@xml.root.elements["columns/col[@id='true']"].nil?
      end


      def has_timestamps?(options={})
        camel_case_attr = options[:camel_case] ? "[@case='camel']" : ""
        !@xml.root.elements["columns/timestamps#{camel_case_attr}"].nil?
      end


      def created_by_column
        has_timestamps?(camel_case: true) ? 'createdBy' : 'created_by'
      end


      def modified_by_column
        has_timestamps?(camel_case: true) ? 'modifiedBy' : 'modified_by'
      end
    end
  end
end
