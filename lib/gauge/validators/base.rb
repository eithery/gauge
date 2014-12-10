# Eithery Lab., 2014.
# Class Gauge::Validators::ValidatorBase
# Represents abstract validator to check a database structure.
require 'gauge'

module Gauge
  module Validators
    class Base
      include Logger

      def self.check_all(validator_name, &block)
        define_method(:do_check_all) do |dbo_schema, dba|
          validator = validator_for validator_name
          block.call(dbo_schema).each do |child_schema|
            validator.errors.clear
            validator.check child_schema, dba
            collect_errors validator
          end
        end
      end


      def self.check_before(validator_name, options={})
        define_method(:do_check_before) do |dbo_schema, dba|
          result = true
          validator = validator_for validator_name
          result = validator.do_validate(dbo_schema, dba)
          collect_errors validator
          result
        end
      end


      def self.check(*validators, &block)
        define_method(:do_check) do |dbo_schema, dba|
          validators.each do |validator_name|
            validator = validator_for validator_name
            actual_dba = block ? block.call(dbo_schema, dba) : dba
            validator.do_validate(dbo_schema, actual_dba)
            collect_errors validator
          end
        end
      end


      def self.validate(&block)
        define_method :do_validate do |dbo_schema, dba|
          instance_exec dbo_schema, dba, &block
        end
      end


      def errors
        @errors ||= []
      end


      def check(dbo_schema, dba)
        result = true
        result = do_check_before(dbo_schema, dba) if respond_to? :do_check_before
        if result
          do_check_all(dbo_schema, dba) if respond_to? :do_check_all
          do_check(dbo_schema, dba) if respond_to? :do_check
        end
      end


      def save_sql(table_name, script_name)
        SQL::Builder.save_sql table_name, script_name, yield
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
