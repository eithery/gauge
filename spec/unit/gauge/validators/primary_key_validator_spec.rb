# Eithery Lab., 2015.
# Gauge::Validators::PrimaryKeyValidator specs.
require 'spec_helper'

module Gauge
  module Validators
    describe PrimaryKeyValidator do
      let(:validator) { PrimaryKeyValidator.new }

      it { should respond_to :do_validate }
      it_behaves_like "any database object validator"


      describe '#validate' do
        context "when primary key is simple (one column) and clustered" do
          before do
            @table_schema = DataTableSchema.new(:master_accounts) do
              col :account_id, id: true
              col :account_number, len: 20
            end
          end

          context "and the actual clustered primary key is defined on the same data column" do
            specify "no validation errors"
          end

          context "and missing the actual primary key" do
            specify "missing primary key"
          end

          context "but the actual primary key is defined on another data column" do
            specify "primary key mismatch"
          end

          context "but the actual primary key is composite" do
            specify "primary key mismatch"
          end

          context "but the actual primary key is nonclustered" do
            specify "primary key mismatch"
          end
        end


        context "wnen primary key is composite (multi-column)" do
          before do
            @table_schema = DataTableSchema.new(:fund_accounts) do
              col :number, id: true
              col :cusip, id: true
              col :code
              col :product_id, type: :long, required: true
            end
          end

          context "and the actual composite primary key is defined on the same set of data columns" do
            specify "no validation errors"
          end

          context "and missing the actual primary key" do
            specify "missing primary key"
          end

          context "but the actual primary key is defined on another set of data columns" do
            specify "primary key mismatch"
          end

          context "but the actual primary key is simple and does not include one column" do
            specify "primary key mismatch"
          end
        end


        context "when primary key is unclustered" do
          before do
            @table_schema = DataTableSchema.new(:master_accounts) do
              col :account_id, id: true
              col :account_number, business_id: true
            end
          end

          context "and the actual unclustered primary key is defined on the same data column" do
            specify "no validation errors"
          end

          context "and missing the actual primary key" do
            specify "missing primary key"
          end

          context "but the actual primary key is clustered" do
            specify "primary key mismatch"
          end
        end
      end
    end
  end
end
