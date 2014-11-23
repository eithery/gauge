# Eithery Lab., 2014.
# Gauge::Validators::ColumnLengthValidator specs.
require 'spec_helper'

module Gauge
  module Validators
    describe ColumnLengthValidator do
      let(:validator) { ColumnLengthValidator.new }
      let(:schema) { @column_schema }

      it { should respond_to :do_validate }
      it_behaves_like "any database object validator"


      describe '#validate' do
        before { @db_column = double('db_column') }

        context "for character columns" do
          context "with specified normal length" do
            before { @column_schema = Schema::DataColumnSchema.new(:rep_code, len: 10) }

            context "in case of mismatched length" do
              before { stub_column_length 6 }
              it { should_append_error(mismatch_message :rep_code, 6, 10) }
            end

            context "in case of equal length" do
              before { stub_column_length 10 }
              specify { no_validation_errors { |schema, dba| validator.do_validate(schema, dba) }}
            end
          end

          context "with specified MAX length" do
            before { @column_schema = Schema::DataColumnSchema.new(:description, len: :max) }

            context "in case of mismatched length" do
              before { stub_column_length 50 }
              it { should_append_error(mismatch_message :description, 50, :max) }
            end

            context "in case of equal length" do
              before { stub_column_length -1 }
              specify { no_validation_errors { |schema, dba| validator.do_validate(schema, dba) }}
            end
          end

          context "with default length" do
            before { @column_schema = Schema::DataColumnSchema.new(:last_name) }

            context "in case of mismatched length" do
              before { stub_column_length 50 }
              it { should_append_error(mismatch_message :last_name, 50,
                Schema::DataColumnSchema::DEFAULT_VARCHAR_LENGTH) }
            end

            context "in case of equal length" do
              before do
                stub_column_length Schema::DataColumnSchema::DEFAULT_VARCHAR_LENGTH
              end
              specify { no_validation_errors { |schema, dba| validator.do_validate(schema, dba) }}
            end
          end
        end


        context "for not character column types" do
          before do
            @column_schema = Schema::DataColumnSchema.new(:total_amount, type: :money)
            stub_column_length nil
          end
          specify { no_validation_errors { |schema, dba| validator.do_validate(schema, dba) }}
        end


        context "for ISO code columns (country, US state)" do
          before { @column_schema = Schema::DataColumnSchema.new(:country_code, type: :country) }

          context "in case of mismatched length" do
            before { stub_column_length 3 }
            it { should_append_error(mismatch_message :country_code, 3, 2) }
          end

          context "in case of equal length" do
            before { stub_column_length 2 }
            specify { no_validation_errors { |schema, dba| validator.do_validate(schema, dba) }}
          end
        end
      end

  private

      def dba
        @db_column
      end


      def stub_column_length(length)
        @db_column.stub(:[]).with(:max_chars).and_return(length)
      end


      def mismatch_message(column_name, actual_length, defined_length)
        /the length of column '(.*)#{column_name}(.*)' is '(.*)#{actual_length}/i
        /(.*)', but it must be '(.*)#{defined_length}(.*)' chars./i
      end
    end
  end
end
