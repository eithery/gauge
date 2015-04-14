# Eithery Lab., 2015.
# Gauge::SQL::Provider specs.

require 'spec_helper'

module Gauge
  module SQL
    describe Provider do
      class SqlProviderMock
        include Provider
      end

      let(:sql_provider) { SqlProviderMock.new }
      subject { sql_provider }


      describe '#build_sql' do
        before do
          @column_schema = double('column_schema')
          @builder = double('sql_builder', build_sql: "alter table ...")
          SQL::Builder.stub(:new => @builder)
        end

        it "delegates build SQL operation to SQL::Builder class" do
          @builder.should_receive(:build_sql).with(:add_column, @column_schema)
          sql_provider.build_sql(:add_column, @column_schema) {}
        end

        it "retains generated SQL script" do
          sql_provider.build_sql(:add_column, @column_schema) {}
          sql_provider.sql.should == 'alter table ...'
        end
      end


      describe '#build_alter_column_sql' do
        before do
          @table = Schema::DataTableSchema.new(:reps)
          @column = Schema::DataColumnSchema.new(:rep_code).in_table @table
        end

        it "builds SQL script to alter column" do
          sql_provider.should_receive(:build_sql).with(:alter_column, @column)
          sql_provider.build_alter_column_sql @column
        end

        context "during SQL script generation" do
          before do
            @sql = double('sql_builder')
            sql_provider.stub(:build_sql) do |*args, &block|
              block.call @sql
            end
          end

          it "builds alter column SQL clause" do
            @sql.as_null_object.should_receive(:alter_table).with(@table)
            @sql.as_null_object.should_receive(:alter_column).with(@column)
            sql_provider.build_alter_column_sql @column
          end
        end
      end


      describe '#delete_sql_files' do
        before { @database = Gauge::Schema::DatabaseSchema.new('rep_profile') }

        context "before database validation check" do
          it "deletes all SQL migration files belong to the database to be checked" do
            FileUtils.should_receive(:remove_dir).once.with(/\/sql\/rep_profile/, hash_including(force: true))
            sql_provider.delete_sql_files @database
          end
        end

        context "before data table validation check" do
          before { @data_table = Gauge::Schema::DataTableSchema.new(:reps, database: @database) }

          it "deletes all SQL migration files belong to the data table to be checked" do
            FileUtils.should_receive(:remove_file).with(/\/sql\/rep_profile\/tables\/create_dbo_reps.sql/,
              hash_including(force: true)).once
            FileUtils.should_receive(:remove_file).with(/\/sql\/rep_profile\/tables\/alter_dbo_reps.sql/,
              hash_including(force: true)).once
            sql_provider.delete_sql_files @data_table
          end
        end
      end
    end
  end
end
