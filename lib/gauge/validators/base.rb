# Eithery Lab, 2017.
# Class Gauge::Validators::Base
# An abstract validator to check a database structure.

require 'gauge'

module Gauge
  module Validators
    class Base
      include Logger

      def self.check_all(validator_name, with_schema:, with_dbo: nil)
        check_all_methods << method_name = "check_all_#{validator_name}".to_sym

        define_method(method_name) do |schema, dbo, sql|
          actual_dbo = with_dbo ? with_dbo.call(dbo, schema) : dbo

          validator = validator_for validator_name
          with_schema.call(schema).each do |s|
            validator.errors.clear
            validator.check s, actual_dbo, sql
            collect_errors_from validator
          end
        end
      end


      def self.check_before(validator_name)
        define_method(:do_check_before) do |schema, dbo, sql|
          result = true
          validator = validator_for validator_name
          result = validator.do_validate(schema, dbo, sql)
          collect_errors_from validator
          result
        end
      end


      def self.check(*validators, with_dbo: nil)
        define_method(:do_check) do |schema, dbo, sql|
          validators.each do |validator_name|
            validator = validator_for validator_name
            actual_dbo = with_dbo ? with_dbo.call(dbo, schema) : dbo
            validator.do_validate(schema, actual_dbo, sql)
            collect_errors_from validator
          end
        end
      end


      def self.validate(&block)
        define_method :do_validate do |schema, dbo, sql|
          instance_exec(schema, dbo, sql, &block)
        end
      end


      def errors
        @errors ||= []
      end


      def check(schema, dbo, sql=nil)
        result = true
        result = do_check_before(schema, dbo, sql) if respond_to? :do_check_before
        if result
          self.class.check_all_methods.each { |method| __send__(method, schema, dbo, sql) }
          do_check(schema, dbo, sql) if respond_to? :do_check
        end
      end


  private

      def validator_for(validator_name)
        validator_type = "Gauge::Validators::#{validator_name.to_s.singularize.camelize}Validator".constantize
        validator_type.new
      end


      def collect_errors_from(validator)
        errors.concat validator.errors
      end


      def self.check_all_methods
        @check_all_methods ||= []
      end
    end
  end
end
