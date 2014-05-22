# Metadata repo.
# Represents a repository containing database metadata info.
require 'gauge'

module Gauge
  class Repo
    include ConsoleListener

    def initialize
      @data_root = File.expand_path(File.dirname(__FILE__) + '/../../db')
    end


    # Validates the specified data object.
    def validate(dbo)
      validator = validator_for dbo
      validator.check(schema dbo) unless validator.nil?
    end

private

    # Returns the validator instance based on the specified database object name.
    def validator_for(dbo)
      return Validators::DatabaseValidator.new if database? dbo
      return Validators::DataTableValidator.new if table? dbo

      error "Database metadata for '#{dbo}' is not found."
    end


    # Determines whether the specified name represents the name of a database
    def database?(dbo_name)
      Dir.exist?("#{@data_root}/#{dbo_name}")
    end


    # Determines whether the specified name represents the name of data table
    def table?(dbo_name)
      Dir["#{@data_root}/**/tables/**/#{dbo_name}.db.xml"].any?
    end


    # Creates and returns the schema for the specified database object.
    def schema(dbo_name)
      database = Schema::DatabaseSchema.new(database_name(dbo_name), @data_root)
      return database if database? dbo_name
      database.tables[dbo_name.downcase] if table? dbo_name
    end


    # Retrieves the database name for the specified database object name.
    def database_name(dbo_name)
      return dbo_name if database? dbo_name

      if table? dbo_name
        table_spec_file = Dir["#{@data_root}/**/tables/**/#{dbo_name}.db.xml"].first
        parts = table_spec_file.split('/')
        return parts[parts.find_index('tables') - 1]
      end

      raise "Database metadata for '#{dbo_name}' is not found."
    end
  end
end
