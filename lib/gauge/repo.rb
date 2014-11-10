# Eithery Lab., 2014.
# Class Gauge::Repo
# Represents a repository containing database metadata info.
require 'gauge'

module Gauge
  class Repo
    include ConsoleListener

    def validate(dbo)
      validator = validator_for dbo
      validator.check(schema dbo) unless validator.nil?
    end

private

    def validator_for(dbo)
      return Validators::DatabaseValidator.new if Schema::MetadataRepo.database? dbo
      return Validators::DataTableValidator.new if Schema::MetadataRepo.table? dbo

      error "Database metadata for '#{dbo}' is not found."
    end


    def schema(dbo_name)
      database = Schema::MetadataRepo.databases[database_name(dbo_name).to_sym]
      return database if Schema::MetadataRepo.database? dbo_name

      if Schema::MetadataRepo.table? dbo_name
        table_schema = database.tables[dbo_name.downcase.to_sym]
        table_schema = database.tables[dbo_name.camelize.downcase.to_sym] if table_schema.nil?
        table_schema
      end
    end


    def database_name(dbo_name)
      return dbo_name if Schema::MetadataRepo.database? dbo_name

      if Schema::MetadataRepo.table? dbo_name
        table_schema = table_template(dbo_name).first
        table_schema = table_template(dbo_name.underscore).first if table_schema.nil?
        table_schema = table_template(dbo_name.split('.').last).first if table_schema.nil?
        parts = table_schema.split('/')
        return parts[parts.find_index('tables') - 1]
      end

      raise "Database metadata for '#{dbo_name}' is not found."
    end
  end
end
