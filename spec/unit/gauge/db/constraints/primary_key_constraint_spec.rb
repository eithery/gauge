# Eithery Lab, 2017
# Gauge::DB::Constraints::PrimaryKeyConstraint specs

require 'spec_helper'

module Gauge
  module DB
    module Constraints
      describe PrimaryKeyConstraint do

        let(:primary_key) { PrimaryKeyConstraint.new(name: 'PK_REPS', table: :reps, columns: :rep_code) }
        let(:composite_key) do
          PrimaryKeyConstraint.new(name: 'pk_fund_accounts', table: :fund_accounts,
            columns: [:fund_account_number, :cusip], clustered: false)
        end

        subject { primary_key }

        it { expect(described_class).to be < CompositeConstraint }
        it { should respond_to :clustered? }
        it { should respond_to :== }


        describe '#clustered?' do
          it "clusterd by default" do
            expect(primary_key).to be_clustered
          end

          it "returns false for a non clustered primary key" do
            key = PrimaryKeyConstraint.new(name: 'pk_reps', table: :reps, columns: :id, clustered: false)
            expect(key).to_not be_clustered
          end

          it "returns true for a clustered primary key" do
            key = PrimaryKeyConstraint.new(name: 'pk_reps', table: :reps, columns: :id, clustered: true)
            expect(key).to be_clustered
          end

          it "return true if 'clustered' option has incorrect value" do
            key = PrimaryKeyConstraint.new(name: 'pk_reps', table: :reps, columns: :id, clustered: 'no')
            expect(key).to be_clustered
          end
        end


        describe '#==' do
          it "returns true for same primary key instances" do
            expect(primary_key.==(primary_key)).to be true
          end

          it "returns true for primary keys on the same table and column" do
            key = PrimaryKeyConstraint.new(name: 'pk_reps', table: :reps, columns: :rep_code)
            expect(key).to_not equal(primary_key)
            expect(key.==(primary_key)).to be true
            expect(primary_key.==(key)).to be true
          end

          it "returns true for primary keys on the same table and column but having different names" do
            key = PrimaryKeyConstraint.new(name: 'pk_primary_reps_123456', table: :reps, columns: :rep_code)
            expect(key.==(primary_key)).to be true
            expect(primary_key.==(key)).to be true
          end

          it "returns false when other primary key is not clustered" do
            key = PrimaryKeyConstraint.new(name: 'PK_REPS', table: :reps, columns: :rep_code, clustered: false)
            expect(key.==(primary_key)).to be false
            expect(primary_key.==(key)).to be false
          end

          context "for composite primary keys" do
            it "returns true for primary keys on same columns in various order" do
              key = PrimaryKeyConstraint.new(name: 'pk_fund_accounts', table: :fund_accounts,
                columns: [:fund_account_number, :cusip], clustered: false)
              inverse_order_key = PrimaryKeyConstraint.new(name: 'pk_fund_accounts', table: :fund_accounts,
                columns: [:cusip, :fund_account_number], clustered: false)

              expect(key.==(composite_key)).to be true
              expect(composite_key.==(key)).to be true
              expect(inverse_order_key.==(composite_key)).to be true
              expect(composite_key.==(inverse_order_key)).to be true
            end

            it "returns false for different number of columns" do
              key = PrimaryKeyConstraint.new(name: 'pk_fund_accounts', table: :fund_accounts,
                columns: [:fund_account_number, :cusip, :ordinal], clustered: false)
              expect(key.==(composite_key)).to be false
              expect(composite_key.==(key)).to be false
            end
          end
        end
      end
    end
  end
end
