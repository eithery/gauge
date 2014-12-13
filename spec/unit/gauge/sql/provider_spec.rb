# Eithery Lab., 2014.
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
          @table = Schema::DataTableSchema.new(:primary_reps)
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

          it "builds SQL script to drop and recreate check constraints" do
            @sql.as_null_object.should_receive(:drop_check_constraints).with(@table)
            @sql.as_null_object.should_receive(:add_check_constraints).with(@table)
            sql_provider.build_alter_column_sql @column
          end

          it "builds SQL script to drop and recreate default constraint" do
            @sql.as_null_object.should_receive(:drop_default_constraint).with(@column)
            @sql.as_null_object.should_receive(:add_default_constraint).with(@column)
            sql_provider.build_alter_column_sql @column
          end

          it "builds alter column SQL clause" do
            @sql.as_null_object.should_receive(:alter_table).with(@table)
            @sql.as_null_object.should_receive(:alter_column).with(@column)
            sql_provider.build_alter_column_sql @column
          end
        end
      end
    end
  end
end
