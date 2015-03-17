# Eithery Lab., 2015.
# Class Gauge::DB::DataColumn
# Encapsulates the actual data column attributes.
require 'gauge'

module Gauge
  module DB
    class DataColumn < DatabaseObject

      def initialize(name, options={})
        super(name)
        @options = options
      end


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
