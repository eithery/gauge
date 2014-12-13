# Eithery Lab., 2014.
# Gauge::Validators::Base specs.
require 'spec_helper'

module Gauge
  module Validators
    class BaseStub < Base
    end

    describe Base do
      let(:validator) { BaseStub.new }

      it_behaves_like "any database object validator"

      describe '.check_all' do
        it "defines 'do_check_all' instance method" do
          expect { BaseStub.check_all(:data_tables) }
            .to change { validator.respond_to? :do_check_all }.from(false).to(true)
        end
      end


      describe '.check_before' do
        it "defines 'do_check_before' instance method" do
          expect { BaseStub.check_before(:data_tables) }
            .to change { validator.respond_to? :do_check_before }.from(false).to(true)
        end
      end


      describe '.check' do
        it "defines 'do_check' instance method" do
          expect { BaseStub.check(:data_tables, :data_columns) }
            .to change { validator.respond_to? :do_check }.from(false).to(true)
        end
      end


      describe '.validate' do
        it "defines 'do_validate' instance method" do
          expect { BaseStub.validate }.to change { validator.respond_to? :do_validate }.from(false).to(true)
        end
      end


      describe '#check' do
        before do
          @dbo_schema = double('dbo_schema')
          @dba = double('dba')
        end

        it "performs preliminary check before main validation stage" do
          validator.should_receive(:do_check_before).with(@dbo_schema, @dba)
          validator.check @dbo_schema, @dba
        end


        context "when preliminary check is passed successfully" do
          before { validator.stub(:do_check_before).and_return(true) }

          it "performs validation check with all inner validators" do
            validator.stub(:do_check)
            validator.should_receive(:do_check_all).with(@dbo_schema, @dba)
            validator.check @dbo_schema, @dba
          end

          it "performs validation check with additional registered validators" do
            validator.stub(:do_check_all)
            validator.should_receive(:do_check).with(@dbo_schema, @dba)
            validator.check @dbo_schema, @dba
          end
        end


        context "when preliminary check is failed" do
          before { validator.stub(:do_check_before).and_return(false) }
          specify "no main validation stage performed" do
            validator.should_not_receive(:do_check_all)
            validator.should_not_receive(:do_check)
            validator.check @dbo_schema, @dba
          end
        end
      end


      describe '#build_sql' do
        before do
          @column_schema = double('column_schema')
          @builder = double('sql_builder', build_sql: "alter table ...")
          SQL::Builder.stub(:new => @builder)
        end

        it "delegates build SQL operation to SQL::Builder class" do
          @builder.should_receive(:build_sql).with(:add_column, @column_schema)
          validator.build_sql(:add_column, @column_schema) {}
        end

        it "retains generated SQL script" do
          validator.build_sql(:add_column, @column_schema) {}
          validator.sql.should == 'alter table ...'
        end
      end


      describe '#build_alter_column_sql' do
        before do
          @table = Schema::DataTableSchema.new(:primary_reps)
          @column = Schema::DataColumnSchema.new(:rep_code).in_table @table
        end

        it "builds SQL script to alter column" do
          validator.should_receive(:build_sql).with(:alter_column, @column)
          validator.build_alter_column_sql @column
        end

        context "during SQL script generation" do
          before do
            @sql = double('sql_builder')
            validator.stub(:build_sql) do |*args, &block|
              block.call @sql
            end
          end

          it "builds SQL script to drop and recreate check constraints" do
            @sql.as_null_object.should_receive(:drop_check_constraints).with(@table)
            @sql.as_null_object.should_receive(:add_check_constraints).with(@table)
            validator.build_alter_column_sql @column
          end

          it "builds SQL script to drop and recreate default constraint" do
            @sql.as_null_object.should_receive(:drop_default_constraint).with(@column)
            @sql.as_null_object.should_receive(:add_default_constraint).with(@column)
            validator.build_alter_column_sql @column
          end

          it "builds alter column SQL clause" do
            @sql.as_null_object.should_receive(:alter_table).with(@table)
            @sql.as_null_object.should_receive(:alter_column).with(@column)
            validator.build_alter_column_sql @column
          end
        end
      end
    end
  end
end
