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
            it { should_not_yield_errors }
          end

          context "and missing the actual primary key" do
            before { @primary_key = nil }
            it { yields_error :missing_primary_key }
          end

          context "but the actual primary key is defined on another data column" do
            before do
              @primary_key = Gauge::DB::Constraints::PrimaryKeyConstraint.new('pk_accounts', :accounts, :number)
            end
            it { yields_error :column_mismatch, expected: [:account_id], actual: [:number] }
          end

          context "but the actual primary key is composite" do
            before do
              @primary_key = Gauge::DB::Constraints::PrimaryKeyConstraint.new('pk_accounts', :accounts,
                [:account_id, :number])
            end
            it { yields_error :column_mismatch, expected: [:account_id], actual: [:account_id, :number] }
          end

          context "but the actual primary key is nonclustered" do
            before do
              @primary_key = Gauge::DB::Constraints::PrimaryKeyConstraint.new('pk_accounts', :accounts,
                :account_id, clustered: false)
            end
            it { yields_error :invalid_key_type, should_be: :clustered }
          end

          context "but the actual primary key has a different name" do
            before do
              @primary_key = Gauge::DB::Constraints::PrimaryKeyConstraint.new('pk_acc1234567', :accounts, :account_id)
            end
            it { should_not_yield_errors }
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
            it { should_not_yield_errors }
          end

          context "but the actual primary key is defined on another set of data columns" do
            before do
              @primary_key = Gauge::DB::Constraints::PrimaryKeyConstraint.new('pk_fund_accounts', :fund_accounts,
                [:product_id, :cusip])
            end
            it do
              yields_error :column_mismatch, expected: [:fund_account_number, :cusip],
                actual: [:product_id, :cusip]
            end
          end

          context "but the actual primary key is simple and does not include one column" do
            before do
              @primary_key = Gauge::DB::Constraints::PrimaryKeyConstraint.new('pk_fund_accounts', :fund_accounts,
                [:fund_account_number])
            end
            it do
              yields_error :column_mismatch, expected: [:fund_account_number, :cusip],
                actual: [:fund_account_number]
            end
          end
        end


        context "when primary key is nonclustered" do
          before do
            @table_schema = Gauge::Schema::DataTableSchema.new(:accounts) do
              col :account_id, id: true
              col :account_number, business_id: true
            end
            primary_key = Gauge::DB::Constraints::PrimaryKeyConstraint.new('pk_accounts', :accounts,
              :account_id, clustered: false)
            @table_schema.stub(:primary_key).and_return(primary_key)
          end

          context "and the actual nonclustered primary key is defined on the same data column" do
            before do
              @primary_key = Gauge::DB::Constraints::PrimaryKeyConstraint.new('pk_accounts', :accounts,
                :account_id, clustered: false)
            end
            it { should_not_yield_errors }
          end

          context "but the actual primary key is clustered" do
            before do
              @primary_key = Gauge::DB::Constraints::PrimaryKeyConstraint.new('pk_accounts', :accounts, :account_id)
            end
            it { yields_error :invalid_key_type, should_be: :nonclustered }
          end
        end
      end

  private

      def dba
        table
      end


      def column_mismatch_message(options)
        expected = options[:expected]
        actual = options[:actual]
        message = "primary key is defined on \\[#{displayed_names_of(actual)}\\] " +
          "column".pluralize(actual.count) + ", but should be on \\[#{displayed_names_of(expected)}\\]"
        /#{message}/i
      end


      def invalid_key_type_message(options)
        message = "Primary key should be (.*?)#{expected_key_type(options)}(.*?), " +
          "but actually it is (.*?)#{actual_key_type(options)}(.*?)"
        /#{message}/
      end


      def missing_primary_key_message(options)
        /Missing (.*?)primary key(.*?) on the data table/
      end


      def expected_key_type(options)
        options[:should_be].to_s
      end


      def actual_key_type(options)
        expected_key_type(options) == key_types.first ? key_types.last : key_types.first
      end


      def key_types
        ['clustered', 'nonclustered']
      end
    end
  end
end
