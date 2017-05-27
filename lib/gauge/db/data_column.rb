# Eithery Lab, 2017
# Class Gauge::DB::DataColumn
# An actual data table column.

require 'gauge'

module Gauge
  module DB
    class DataColumn < DatabaseObject

      def initialize(name:, options: {})
        super(name: name)
        @options = options
      end


      def column_id
        name.to_s.downcase.to_sym
      end

      alias_method :to_sym, :column_id


      def data_type
        @options[:db_type].to_sym
      end


      def allow_null?
        @options[:allow_null]
      end


      def length
        @options[:max_chars]
      end


      def default_value
        default = @options[:ruby_default].nil? ? @options[:default] : @options[:ruby_default]
        return sequel_constant(default) if default.kind_of? Sequel::SQL::Constant
        return $1 if default.to_s =~ /\A\((.*)\)\z/i
        default
      end


  private

      def sequel_constant(default_value)
        value = default_value.constant
        value == :CURRENT_TIMESTAMP ? :current_timestamp : value
      end
    end
  end
end
