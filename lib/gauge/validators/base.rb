# Eithery Lab., 2014.
# Class Gauge::Validators::ValidatorBase
# Represents abstract validator to check a database structure.
require 'gauge'

module Gauge
  module Validators
    class Base
      include ConsoleListener

      def self.check_all(validator_name, &block)
        validator_type = "Gauge::Validators::#{validator_name.to_s.singularize.camelize}Validator".constantize
        define_method(:do_check_all) do |dbo_schema, dba|
          validator = validator_type.new
          block.call(dbo_schema).each do |child_schema|
            validator.errors.clear
            validator.check child_schema, dba
            errors.concat validator.errors
          end
        end
      end


      def self.check_before(validator_name, options={})
        validator_type = "Gauge::Validators::#{validator_name.to_s.singularize.camelize}Validator".constantize
        define_method(:do_check_before) do |dbo_schema, dba|
          result = true
          validator = validator_type.new
          result = validator.do_validate(dbo_schema, dba)
          errors.concat validator.errors
          result
        end
      end


      def self.check(*validators, &block)
        validator_types = validators.map do |val|
          "Gauge::Validators::#{val.to_s.singularize.camelize}Validator".constantize
        end
        define_method(:do_check) do |dbo_schema, dba|
          validator_types.each do |val_type|
            validator = val_type.new
            actual_dba = block ? block.call(dbo_schema, dba) : dba
            validator.do_validate(dbo_schema, actual_dba)
            errors.concat validator.errors
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
    end
  end
end
