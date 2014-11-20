# Eithery Lab., 2014.
# Gauge::DB::Adapter specs.
require 'spec_helper'

module Gauge
  module DB
    describe Adapter do
      subject { Adapter }

      it { should respond_to :session }

      describe '.session' do
        before do
          stub_db_adapter
          @db_schema = Schema::DatabaseSchema.new(:test_db)
        end

        it "uses tinyTDS database adapter" do
          Sequel.should_receive(:tinytds).with hash_including(database: @db_schema.sql_name)
          Adapter.session(@db_schema)
        end

        it "performs preliminary check of database connection" do
          Sequel::TinyTDS::Database.any_instance.should_receive(:test_connection)
          Adapter.session(@db_schema) { |dba| }
        end
      end
    end
  end
end
