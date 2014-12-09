# Eithery Lab., 2014.
# Class Gauge::Inspector
# Performs various validation checks of the specified database or
# particular database objects structure against the predefined schema.
require 'gauge'
require_relative 'logger'

module Gauge
  class Inspector
    include Logger

    def initialize(global_opts, options)
      DB::Connection.configure global_opts
    end


    def check(args)
      if args.empty?
        error 'No database objects specified to be inspected.'
        return
      end

      Schema::Repo.load
      args.each do |dbo|
        validator = validator_for dbo
        schema = Schema::Repo.schema dbo
        unless schema.nil?
          log "== #{schema.object_name} '#{schema.sql_name}' inspecting ".ljust(80, '=')
          DB::Adapter.session schema do |dba|
            validator.check(schema, dba) unless validator.nil?
          log "== #{schema.object_name} '#{schema.sql_name}' inspected ".ljust(80, '=')
          end
        else
          error "Database metadata for '#{dbo}' is not found."
        end
      end
    end

private

    def validator_for(dbo)
      return Validators::DatabaseValidator.new if Schema::Repo.database? dbo
      Validators::DataTableValidator.new if Schema::Repo.table? dbo
    end
  end
end
