# Eithery Lab., 2014.
# Class Gauge::DatabaseInspector
# Performs various validation checks of the specified database or
# particular database objects structure against the predefined schema.
require 'gauge'

module Gauge
  class DatabaseInspector
    include ConsoleListener

    def initialize(global_opts, options, args)
      @args = args
      DB::Connection.configure global_opts
    end


    def check
      if @args.empty?
        error 'No database objects specified to be inspected.'
        return
      end

      Schema::MetadataRepo.load
      @args.each do |dbo|
        validator = validator_for dbo
        validator.check(Schema::MetadataRepo.schema dbo) unless validator.nil?
      end
    end

private

    def validator_for(dbo)
      return Validators::DatabaseValidator.new if Schema::MetadataRepo.database? dbo
      return Validators::DataTableValidator.new if Schema::MetadataRepo.table? dbo

      error "Database metadata for '#{dbo}' is not found."
    end
  end
end
