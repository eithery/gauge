# Eithery Lab., 2014.
# Class Gauge::DB::DataColumn
# Encapsulates the actual data column attributes.
require 'gauge'

module Gauge
  module DB
    class DataColumn

      def initialize(db_column)
        @db_column = db_column
      end


      def data_type
        @db_column[:db_type].to_sym
      end


      def allow_null?
        @db_column[:allow_null]
      end


      def length
        @db_column[:max_chars]
      end


      def default_value
        default = @db_column[:ruby_default].nil? ? @db_column[:default] : @db_column[:ruby_default]
        return sequel_constant(default) if default.kind_of? Sequel::SQL::Constant
        return $1 if default.to_s =~ /\A\((.*)\)\z/i
        default
      end

  private

      def sequel_constant(default_value)
        value = default_value.constant
        value == :CURRENT_TIMESTAMP ? 'getdate()' : value
      end
    end
  end
end
