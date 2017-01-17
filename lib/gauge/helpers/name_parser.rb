# Eithery Lab, 2017
# Class Gauge::Helpers::NameParser
# Provides helper methods to parse database object names.

require 'gauge'

module Gauge
  module Helpers
    class NameParser

      def self.local_name_of(dbo_name)
        parsed_name(dbo_name).last
      end


      def self.sql_schema_of(dbo_name)
        schema = parsed_name(dbo_name)[-2]
        schema.blank? ? 'dbo' : schema
      end


      def self.dbo_key_of(dbo_name)
        "#{sql_schema_of(dbo_name)}_#{local_name_of(dbo_name)}".downcase.to_sym
      end


  private

      def self.parsed_name(dbo_name)
        dbo_name.to_s.gsub(/\[|\]|\"|^dbo_/i, '').split('.')
      end
    end
  end
end
