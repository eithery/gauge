# Eithery Lab., 2014.
# Class Gauge::Schema::DataTableSchema.
# Data table schema.
# Contains metadata info defining a data table structure.
require 'gauge'

module Gauge
	module Schema
		class DataTableSchema
			attr_reader :local_name, :schema, :columns
			private :local_name

			# Creates the new instance of DataTableSchema class.
			def initialize(schema_file)
				raise "Metadata file '#{schema_file}' not found." unless File.exists?(schema_file)
				@table_schema = schema_file
				@columns = []
				File.open(schema_file, 'r') { |file| parse_xml REXML::Document.new(file) }
			end


			# Returns the database containing the table.
			def database
				parts = @table_schema.split('/')
				parts[parts.find_index('tables') - 1]
			end


			# Returns the full table name.
			def table_name
				@schema.nil? ? @local_name : @schema + '.' + @local_name
			end


			def to_key
				local_name.to_sym.downcase
			end


		private
			def parse_xml(xml_doc)
				@local_name = xml_doc.root.attributes['name']
				@schema = xml_doc.root.attributes['schema']
				xml_doc.root.each_element('/table/columns/col') do |col|
					column_attributes = {}
					col.attributes.each { |name, value|	column_attributes[name.to_sym] = value }
					@columns << DataColumnSchema.new(column_attributes)
				end
				if has_timestamps?(xml_doc)
					@columns << DataColumnSchema.new(:name => 'created', :type => 'datetime', :required => true)
					@columns << DataColumnSchema.new(:name => 'created_by', :required => true)
					@columns << DataColumnSchema.new(:name => 'modified', :type => 'datetime', :required => true)
					@columns << DataColumnSchema.new(:name => 'modified_by', :required => true)
					@columns << DataColumnSchema.new(:name => 'version', :type => 'long', :required => true)
				end
			end


			def has_timestamps?(xml_doc)
				!xml_doc.root.elements['columns/timestamps'].nil?
			end
		end
	end
end
