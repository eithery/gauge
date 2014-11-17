# Eithery Lab., 2014.
# Class Gauge::Validators::ValidatorSpecHelper
# Provides the set of helper methods for Validator specs.
module Gauge
  module Validators
    module ValidatorSpecHelper

      def create_dba_stubs
        @dba = double('dba', table_exists?: true, column_exists?: true, column: @db_column)
      end


      def create_data_column_stubs
        @column_schema = double('column_schema', column_name: 'account_number')
        @db_column = double('db_column')

        @db_column.stub(:[]).with(:allow_null)
          .and_return(false, false, true, false, false, true)
        @db_column.stub(:[]).with(:db_type)
          .and_return(:bigint, :nvarchar, :datetime, :bigint, :nvarchar, :datetime)
      end


      def create_data_table_stubs
        @table_schema = double('table_schema', table_name: 'dbo.master_accounts',
          sql_schema: :ref, local_name: 'master_accounts',
          columns: [
            double(column_name: 'id', data_type: :bigint, allow_null?: false),
            double(column_name: 'number', data_type: :nvarchar, allow_null?: false),
            double(column_name: 'created_at', data_type: :datetime, allow_null?: true)
          ])
      end


      def stub_column_schema_nullability(nullability)
        allow_null = nullability == :null
        @column_schema.stub(:allow_null?).and_return(allow_null)
      end


      def stub_db_column_nullability(nullability)
        allow_null = nullability == :null
        @db_column.stub(:[]).with(:allow_null).and_return(allow_null)
      end


      def stub_column_schema_type(column_data_type)
        @column_schema.stub(:data_type).and_return(column_data_type)
      end


      def stub_db_column_type(column_data_type)
        @db_column.stub(:[]).with(:db_type).and_return(column_data_type)
      end


      def stub_validator(validator_class)
        validator = validator_class.new
        validator_class.stub(:new).and_return(validator)
        validator
      end


      def stub_db_adapter
        DB::Connection.stub(:server).and_return('local\SQL2012')
        DB::Connection.stub(:user).and_return('admin')
        DB::Connection.stub(:password).and_return('secret')
        Sequel::TinyTDS::Database.any_instance.stub(:test_connection)
      end


      def no_validation_errors_detected
        expect { validator.check(@schema, @dba) }.not_to change { validator.errors.count }

        validator.errors.should_not_receive(:<<)
        validator.check(@schema, @dba)
        validator.errors.should be_empty
      end


      def should_append_error_message(error_message)
        validator.errors.should_receive(:<<).with(error_message)
        validator.validate(@schema, @dba)
      end


      shared_examples_for "any database object validator" do
        subject { validator }

        it { should respond_to :check }
        it { should respond_to :errors }

        specify { validator.class.should respond_to :check_all }
        specify { validator.class.should respond_to :check }
        specify { validator.class.should respond_to :validate }

        specify { validator.errors.should_not be_nil }
        specify { validator.errors.should be_empty }
      end


      shared_examples_for "validation passed successfully" do
        specify "errors collection remains empty" do
          no_validation_errors_detected
        end
      end
    end
  end
end
