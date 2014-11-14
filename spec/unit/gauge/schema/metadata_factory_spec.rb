# Eithery Lab., 2014.
# Gauge::Schema::MetadataFactory specs.
require 'spec_helper'

module Gauge
  module Schema
    describe MetadataFactory do
      subject { MetadataFactory }

      it { should respond_to :define_database, :define_table }

      describe '.define_database' do
        before { Repo.databases.clear }

        it "creates database metadata definition" do
          DatabaseSchema.should_receive(:new).with(:rep_profile, hash_including(:sql_name))
          MetadataFactory.define_database(:rep_profile, sql_name: 'RepProfile')
        end

        it "registers database metadata in the repository" do
          MetadataFactory.define_database(:rep_profile, sql_name: 'RepProfile')
          Repo.databases.should include(:rep_profile)
        end
      end


      describe ".define_table" do
        it "Creates data table metadata definition" do
          table_schema = double('rep_profile', database_name: :rep_profile, to_key: :offices)
          DataTableSchema.should_receive(:new).and_return(table_schema)
          MetadataFactory.define_table(:primary_reps)
        end

        it "Registers data table metadata definition in the database metadata" do
          MetadataFactory.define_table(:primary_reps)
          Repo.databases[:rep_profile].tables.should include(:primary_reps)
        end
      end
    end
  end
end
