# Eithery Lab., 2015.
# Gauge::Validators::PrimaryKeyValidator specs.

require 'spec_helper'

module Gauge
  module Validators
    describe PrimaryKeyValidator do
      let(:validator) { PrimaryKeyValidator.new }
      let(:schema) { @table_schema }
      let(:table) { double('table', primary_key: @primary_key) }

      it { should respond_to :do_validate }
      it_behaves_like "any database object validator"


      describe '#validate' do
        context "when the primary key is simple (one column) and clustered" do
          before do
            @table_schema = Gauge::Schema::DataTableSchema.new(:accounts) do
              col :account_id, id: true
              col :account_number, len: 20
            end
            primary_key = Gauge::DB::Constraints::PrimaryKeyConstraint.new('pk_accounts', :accounts, :account_id)
            @table_schema.stub(:primary_key).and_return(primary_key)
          end

          context "and the actual clustered primary key is defined on the same data column" do
            before do
              @primary_key = Gauge::DB::Constraints::PrimaryKeyConstraint.new('pk_accounts', :accounts, :account_id)
            end
            specify { no_validation_errors { |schema, dba| validator.do_validate(schema, dba) } }
          end

          context "and missing the actual primary key" do
            before { @primary_key = nil }
            it { should_append_error(/missing primary key/i) }
          end

          context "but the actual primary key is defined on another data column" do
            before do
              @primary_key = Gauge::DB::Constraints::PrimaryKeyConstraint.new('pk_accounts', :accounts, :number)
            end
            it { should_append_error(/primary keys mismatch/i) }
          end

          context "but the actual primary key is composite" do
            before do
              @primary_key = Gauge::DB::Constraints::PrimaryKeyConstraint.new('pk_accounts', :accounts,
                [:account_id, :number])
            end
            it { should_append_error(/primary keys mismatch/i) }
          end

          context "but the actual primary key is nonclustered" do
            before do
              @primary_key = Gauge::DB::Constraints::PrimaryKeyConstraint.new('pk_accounts', :accounts,
                :account_id, clustered: false)
            end
            it { should_append_error(/primary keys mismatch/i) }
          end

          context "but the actual primary key has a different name" do
            before do
              @primary_key = Gauge::DB::Constraints::PrimaryKeyConstraint.new('pk_acc1234567', :accounts, :account_id)
            end
            specify { no_validation_errors { |schema, dba| validator.do_validate(schema, dba) } }
          end
        end


        context "wnen the primary key is composite (multi-column)" do
          before do
            @table_schema = Gauge::Schema::DataTableSchema.new(:fund_accounts) do
              col :fund_account_number, id: true
              col :cusip, id: true
              col :code
              col :product_id, type: :long, required: true
            end
            primary_key = Gauge::DB::Constraints::PrimaryKeyConstraint.new('pk_fund_accounts', :fund_accounts,
              [:fund_account_number, :cusip])
            @table_schema.stub(:primary_key).and_return(primary_key)
          end

          context "and the actual composite primary key is defined on the same set of data columns" do
            before do
              @primary_key = Gauge::DB::Constraints::PrimaryKeyConstraint.new('pk_fund_accounts', :fund_accounts,
                [:cusip, :fund_account_number])
            end
            specify { no_validation_errors { |schema, dba| validator.do_validate(schema, dba) } }
          end

          context "but the actual primary key is defined on another set of data columns" do
            before do
              @primary_key = Gauge::DB::Constraints::PrimaryKeyConstraint.new('pk_fund_accounts', :fund_accounts,
                [:product_id, :cusip])
            end
            it { should_append_error(/primary keys mismatch/i) }
          end

          context "but the actual primary key is simple and does not include one column" do
            before do
              @primary_key = Gauge::DB::Constraints::PrimaryKeyConstraint.new('pk_fund_accounts', :fund_accounts,
                [:fund_account_number])
            end
            it { should_append_error(/primary keys mismatch/i) }
          end
        end


        context "when primary key is unclustered" do
          before do
            @table_schema = Gauge::Schema::DataTableSchema.new(:accounts) do
              col :account_id, id: true
              col :account_number, business_id: true
            end
            primary_key = Gauge::DB::Constraints::PrimaryKeyConstraint.new('pk_accounts', :accounts,
              :account_id, clustered: false)
            @table_schema.stub(:primary_key).and_return(primary_key)
          end

          context "and the actual unclustered primary key is defined on the same data column" do
            before do
              @primary_key = Gauge::DB::Constraints::PrimaryKeyConstraint.new('pk_accounts', :accounts,
                :account_id, clustered: false)
            end
            specify { no_validation_errors { |schema, dba| validator.do_validate(schema, dba) } }
          end

          context "but the actual primary key is clustered" do
            before do
              @primary_key = Gauge::DB::Constraints::PrimaryKeyConstraint.new('pk_accounts', :accounts, :account_id)
            end
            it { should_append_error(/primary keys mismatch/i) }
          end
        end
      end

  private

      def dba
        table
      end
    end
  end
end
