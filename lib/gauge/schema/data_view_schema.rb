# Eithery Lab, 2017
# Class Gauge::Schema::DataViewSchema
# Defines a data view.

require 'gauge'

module Gauge
  module Schema
    class DataViewSchema
      include Gauge::Helpers::NamesHelper

      attr_reader :sql_schema

      def initialize(name:, sql_schema: nil, db:, &block)
        @local_name = local_name_of(name)
        @sql_schema = sql_schema.nil? ? sql_schema_of(name).to_sym : sql_schema.to_s.downcase.to_sym
        @database = db.to_s.downcase.to_sym
      end


      def view_id
        "#{sql_schema}_#{local_name}".downcase.to_sym
      end


      def local_name
        @local_name.to_s
      end
    end
  end
end
