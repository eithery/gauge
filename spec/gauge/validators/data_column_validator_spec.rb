# Eithery Lab., 2014.
# Gauge::Validators::DataColumnValidator specs.
require 'spec_helper'

module Gauge
  module Validators
    describe DataColumnValidator do
      let(:validator) { DataColumnValidator.new }
      it_behaves_like "any database object validator"

      describe '#validate' do
        before do
          create_data_column_stubs
          @dba.stub(:column_exists?).and_return(true)
          @column_schema.stub(:allow_null?).and_return(true)
          @column_schema.stub(:data_type).and_return(:nvarchar)
          @db_column.stub(:[]).with(:allow_null).and_return(true)
          @db_column.stub(:[]).with(:db_type).and_return(:nvarchar)
        end

        it "performs check for missing data columns" do
          missing_column_validator = MissingColumnValidator.new
          MissingColumnValidator.stub(:new).and_return(missing_column_validator)
          missing_column_validator.should_receive(:validate).with(@column_schema, @dba)
          validator.validate @column_schema, @dba
        end

        it "performs data column type validation" do
          column_type_validator = ColumnTypeValidator.new
          ColumnTypeValidator.stub(:new).and_return(column_type_validator)
          column_type_validator.should_receive(:validate).with(@column_schema, @db_column)
          validator.validate @column_schema, @dba
        end

        it "performs data column nullability check" do
          nullability_validator = ColumnNullabilityValidator.new
          ColumnNullabilityValidator.stub(:new).and_return(nullability_validator)
          nullability_validator.should_receive(:validate).with(@column_schema, @db_column)
          validator.validate @column_schema, @dba
        end

        it "aggregates all errors in the errors collection"
      end
    end
  end
end
