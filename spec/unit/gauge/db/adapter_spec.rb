# Eithery Lab., 2014.
# Gauge::DB::Adapter specs.
require 'spec_helper'

module Gauge
  module DB
    describe Adapter do
      subject { Adapter }

      it { should respond_to :session }
      it { should respond_to :database }

      describe '.session' do
        before do
          stub_db_adapter
          @db_schema = Schema::DatabaseSchema.new(:test_db)
        end

        it "uses tinyTDS database adapter" do
          Sequel.should_receive(:tinytds).with hash_including(database: @db_schema.database_schema.sql_name)
          Adapter.session(@db_schema)
        end

        it "performs preliminary check of database connection" do
          Sequel::TinyTDS::Database.any_instance.should_receive(:test_connection)
          Adapter.session(@db_schema) { |dba| }
        end
      end


      describe '.database' do
        context "in the active session context" do
          before do
            @db_schema = Schema::DatabaseSchema.new('books_n_records')
            @dba = double('database', test_connection: nil)
            Sequel.stub(:tinytds) { |*args, &block| block.call @dba }
          end

          it "returns the current open database instance" do
            Adapter.database.should be nil
            Adapter.session @db_schema do |dba|
              Adapter.database.should_not be nil
              Adapter.database.should be_equal(dba)
              Adapter.database.should be_equal(@dba)
            end
            Adapter.database.should be nil
          end
        end

        context "out of session context" do
          subject { Adapter.database }
          it { should be nil }
        end
      end
    end
  end
end
