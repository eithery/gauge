# Eithery Lab., 2015.
# Class Gauge::Inspector
# Performs various validation checks of the specified database or
# particular database objects structure against the predefined schema.

require 'gauge'
require_relative 'logger'

module Gauge
  class Inspector
    include Logger

    def initialize(global_opts, options)
      Logger.configure(colored: global_opts[:colored])
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
          begin
            info "== #{schema.object_name} '#{schema.sql_name}' inspecting ".ljust(80, '=')
            DB::Adapter.session schema do |dba|
              validator.check(schema, dba) unless validator.nil?
            end
          rescue Sequel::DatabaseConnectionError => e
            error e.message
            validator.errors << e.message
          ensure
            info "== #{schema.object_name} '#{schema.sql_name}' inspected ".ljust(80, '=')
            print_total validator
          end
        else
          error "Database metadata for '<b>#{dbo}</b>' is not found."
        end
      end
    end

private

    def validator_for(dbo)
      return Validators::DatabaseValidator.new if Schema::Repo.database? dbo
      Validators::DataTableValidator.new if Schema::Repo.table? dbo
    end


    def print_total(validator)
      validator.errors.empty? ? ok('<b>ok</b>') : error("Total errors found: #{validator.errors.count}")
    end
  end
end
