# Eithery Lab., 2015.
# Class Gauge::Validators::ValidatorBase
# Represents abstract validator to check a database structure.

require 'gauge'

module Gauge
  module Validators
    class Base
      include Logger
      include SQL::Provider

      def self.check_all(validator_name, options={})
        define_method(:do_check_all) do |dbo_schema, dbo|
          db_schema_provider = options[:with_schema]
          validator = validator_for validator_name
          db_schema_provider.call(dbo_schema).each do |schema|
            validator.errors.clear
            validator.check schema, dbo
            collect_errors validator
          end
        end
      end


      def self.check_before(validator_name, options={})
        define_method(:do_check_before) do |dbo_schema, dbo|
          result = true
          validator = validator_for validator_name
          result = validator.do_validate(dbo_schema, dbo)
          collect_errors validator
          result
        end
      end


      def self.check(*validators, options)
        define_method(:do_check) do |dbo_schema, dbo|
          dbo_provider = options[:with_dbo]
          validators.each do |validator_name|
            validator = validator_for validator_name
            actual_dbo = dbo_provider ? dbo_provider.call(dbo_schema, dbo) : dbo
            validator.do_validate(dbo_schema, actual_dbo)
            collect_errors validator
          end
        end
      end


      def self.validate(&block)
        define_method :do_validate do |dbo_schema, dbo|
          instance_exec dbo_schema, dbo, &block
        end
      end


      def errors
        @errors ||= []
      end


      def check(dbo_schema, dbo)
        result = true
        result = do_check_before(dbo_schema, dbo) if respond_to? :do_check_before
        if result
          do_check_all(dbo_schema, dbo) if respond_to? :do_check_all
          do_check(dbo_schema, dbo) if respond_to? :do_check
        end
      end


      def db_object(dbo)
        dbo
      end

  private

      def validator_for(validator_name)
        validator_type = "Gauge::Validators::#{validator_name.to_s.singularize.camelize}Validator".constantize
        validator_type.new
      end


      def collect_errors(validator)
        errors.concat validator.errors
      end
    end
  end
end
