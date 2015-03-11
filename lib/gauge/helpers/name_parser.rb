# Eithery Lab., 2015.
# Class Gauge::Helpers::NameParser
# Provides the set of helper methods to parse database object names.

require 'gauge'

module Gauge
  module Helpers
    class NameParser

      def self.local_name(dbo_name)
        parsed_name(dbo_name).last
      end


      def self.sql_schema(dbo_name)
        schema = parsed_name(dbo_name)[-2]
        schema.blank? ? 'dbo' : schema
      end


      def self.dbo_key(dbo_name)
        "#{sql_schema(dbo_name)}_#{local_name(dbo_name)}".downcase.to_sym
      end

  private

      def self.parsed_name(dbo_name)
        dbo_name.to_s.gsub(/\[|\]|\"/, '').split('.')
      end
    end
  end
end
