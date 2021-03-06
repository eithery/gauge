# Eithery Lab., 2015.
# Gauge::Validators::DefaultConstraintValidator specs.

require 'spec_helper'

module Gauge
  module Validators
    describe DefaultConstraintValidator do
      let(:validator) { DefaultConstraintValidator.new }
      let(:schema) { @column_schema }
      let(:sql) { SQL::Builder.new }

      it { should respond_to :do_validate }
      it_behaves_like "any database object validator"


      describe '#validate' do
        before do
          stub_file_system
          @db_column = double('db_column')
        end

        context "for enumeration (integer) columns" do
          before { @column_schema = Schema::DataColumnSchema.new(:account_status, required: true, default: 1) }

          context "with matched column default constraint" do
            before { stub_column_default 1 }
            it { should_not_yield_errors }
          end

          context "with the column default constraint mismatch" do
            before { stub_column_default 0 }
            it { should_append_error(mismatch_message :account_status, 1, 0) }
          end

          context "with missing column default constraint" do
            before { stub_column_default nil }
            it { should_append_error(mismatch_message :account_status, 1, nil) }
          end
        end


        context "for boolean columns" do
          before { @column_schema = Schema::DataColumnSchema.new(:is_active, required: true, default: true) }

          context "with matched column default constraint" do
            before { stub_column_default 1 }
            it { should_not_yield_errors }
          end

          context "with the column default constraint mismatch" do
            before { stub_column_default 0 }
            it { should_append_error(mismatch_message :is_active, true, false) }
          end

          context "with missing column default constraint" do
            before { stub_column_default nil }
            it { should_append_error(mismatch_message :is_active, true, nil) }
          end
        end


        context "when no default constraints required" do
          before { @column_schema = Schema::DataColumnSchema.new(:rep_code) }

          context "but the column has default constraint" do
            before { stub_column_default '151045' }
            it { should_append_error(mismatch_message :rep_code, nil, '151045') }
          end

          context "and the column also does not have default constraint" do
            before { stub_column_default nil }
            it { should_not_yield_errors }
          end
        end


        context "when default value is integer UID" do
          before { @column_schema = Schema::DataColumnSchema.new(:trade_id, default: :uid) }

          context "with matched column default constraint" do
            before { stub_column_default 'abs(CONVERT([bigint],CONVERT([varbinary],newid())))' }
            it { should_not_yield_errors }
          end

          context "with missing column default constraint" do
            before { stub_column_default nil }
            it { should_append_error(mismatch_message :trade_id, uid_value_for_mismatch, nil) }
          end

          context "with the column default constraint mismatch" do
            before { stub_column_default 'invalid_default_value' }
            it { should_append_error(mismatch_message :trade_id, uid_value_for_mismatch, 'invalid_default_value') }
          end
        end


        context "when default value is SQL function" do
          before { @column_schema = Schema::DataColumnSchema.new(:modified_at, default: { function: :host_name }) }

          context "with matched column default constraint" do
            before { stub_column_default 'host_name()' }
            it { should_not_yield_errors }
          end

          context "with missing column default constraint" do
            before { stub_column_default nil }
            it { should_append_error(mismatch_message :modified_at, sql_function_for_mismatch, nil) }
          end

          context "with the column default constraint mismatch" do
            before { stub_column_default 'invalid_function' }
            it { should_append_error(mismatch_message :modified_at, sql_function_for_mismatch, 'invalid_function') }
          end
        end
      end

  private

      def dba
        @db_column
      end


      def stub_column_default(default_value)
        @db_column.stub(:default_value).and_return(default_value)
      end


      def mismatch_message(column_name, expected_default, actual_default)
        /#{column_name_message(column_name) + message_content(expected_default, actual_default)}/
      end


      def message_content(expected_default, actual_default)
        return missing_constraint_message expected_default if actual_default.nil?
        return redundant_constraint_message actual_default if expected_default.nil?
        return constraint_mismatch_message expected_default, actual_default
      end


      def column_name_message(column_name)
        "column '(.*?)#{column_name.to_s}(.*?)' "
      end


      def missing_constraint_message(expected_value)
        "- missing default value '(.*?)#{expected_value.to_s}(.*?)'"
      end


      def constraint_mismatch_message(expected_value, actual_value)
        "should have '(.*?)#{expected_value.to_s}(.*?)' as default value, but actually has " +
        "'(.*?)#{actual_value.to_s}(.*?)'"
      end


      def redundant_constraint_message(actual_value)
        "should (.*?)NOT(.*?) have default value, but actually has '(.*?)#{actual_value.to_s}(.*?)'"
      end


      def uid_value_for_mismatch
        'abs\(convert\(bigint,convert\(varbinary,newid\(\)\)\)\)'
      end


      def sql_function_for_mismatch
        'host_name\(\)'
      end
    end
  end
end
