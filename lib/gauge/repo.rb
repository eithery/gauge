# Eithery Lab., 2014.
# Class Gauge::Repo
# Represents a repository containing database metadata info.
require 'gauge'

module Gauge
  class Repo
    include ConsoleListener

    def validate(dbo)
      validator = validator_for dbo
      validator.check(Schema::MetadataRepo.schema dbo) unless validator.nil?
    end

private

    def validator_for(dbo)
      return Validators::DatabaseValidator.new if Schema::MetadataRepo.database? dbo
      return Validators::DataTableValidator.new if Schema::MetadataRepo.table? dbo

      error "Database metadata for '#{dbo}' is not found."
    end
  end
end
