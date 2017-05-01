# Eithery Lab, 2017
# Gauge::DB::Index specs

require 'spec_helper'

module Gauge
  module DB
    describe Index do

      let(:index) { Index.new(name: 'IDX_REP_CODE', table: :reps, columns: :rep_code) }
      let(:composite_index) do
        Index.new(name: 'idx_fund_accounts', table: :fund_accounts, columns: [:fund_account_number, :cusip])
      end

      subject { index }

      it { expect(described_class).to be < Constraints::CompositeConstraint }

      it { should respond_to :clustered? }
      it { should respond_to :unique? }
      it { should respond_to :== }


      describe '#clustered?' do
        it "non-clustered by default" do
          expect(index).to_not be_clustered
        end

        it "returns false for a non-clustered index" do
          index = Index.new(name: 'idx_rep_code', table: :reps, columns: :rep_code, clustered: false)
          expect(index).to_not be_clustered
        end

        it "returns true for a clustered index" do
          index = Index.new(name: 'idx_rep_code', table: :reps, columns: :rep_code, clustered: true)
          expect(index).to be_clustered
        end

        it "returns false if 'clustered' option has incorrect value" do
          index = Index.new(name: 'idx_rep_code', table: :reps, columns: :rep_code, clustered: 'yes')
          expect(index).to_not be_clustered
        end
      end


      describe '#unique?' do
        it "not-unique by default" do
          expect(index).to_not be_unique
        end

        it "returns true for a unique index" do
          index = Index.new(name: 'idx_rep_code', table: :reps, columns: :rep_code, unique: true)
          expect(index).to be_unique
        end

        it "returns true for a clustered index" do
          index = Index.new(name: 'idx_rep_code', table: :reps, columns: :rep_code, clustered: true)
          expect(index).to be_unique
        end

        it "returns true for a clustered but not unique index" do
          index = Index.new(name: 'idx_rep_code', table: :reps, columns: :rep_code, clustered: true, unique: false)
          expect(index).to be_unique
        end

        it "returns false for a non-unique index" do
          index = Index.new(name: 'idx_rep_code', table: :reps, columns: :rep_code, unique: false)
          expect(index).to_not be_unique
        end

        it "returns false if 'unique' option has incorrect value" do
          index = Index.new(name: 'idx_rep_code', table: :reps, columns: :rep_code, unique: 'yes')
          expect(index).to_not be_unique
        end
      end


      describe '#==' do
        it "returns true for indexes on the same table and column" do
          idx = Index.new(name: 'idx_reps_rep_code', table: :reps, columns: :rep_code)
          expect(index).to_not equal(idx)
          expect(index.==(idx)).to be true
          expect(idx.==(index)).to be true
        end

        it "returns true for indexes on the same table and column but having different names" do
          idx = Index.new(name: 'idx_primary_reps_123456', table: :reps, columns: :rep_code)
          expect(index.==(idx)).to be true
          expect(idx.==(index)).to be true
        end

        it "returns false when other index is unique" do
          unique_index = Index.new(name: 'idx_reps_rep_code', table: :reps, columns: :rep_code, unique: true)
          expect(index.==(unique_index)).to be false
          expect(unique_index.==(index)).to be false
        end

        context "for composite indexes" do
          it "returns true for indexes on same columns in various order" do
            idx = Index.new(name: 'idx_fund_accounts', table: :fund_accounts,
              columns: [:fund_account_number, :cusip])
            inverse_order_index = Index.new(name: 'idx_fund_accounts', table: :fund_accounts,
              columns: [:cusip, :fund_account_number])

            expect(idx.==(composite_index)).to be true
            expect(composite_index.==(idx)).to be true
            expect(inverse_order_index.==(composite_index)).to be true
            expect(composite_index.==(inverse_order_index)).to be true
          end

          it "returns false for different number of columns" do
            idx = Index.new(name: 'idx_fund_accounts', table: :fund_accounts,
              columns: [:fund_account_number, :cusip, :ordinal])
            expect(idx.==(composite_index)).to be false
            expect(composite_index.==(idx)).to be false
          end
        end

        context "for clustered indexes" do
          it "is not equal to a non-clustered unique index on the same column" do
            clustered_index = Index.new(name: 'idx_reps_rep_code', table: :reps,
              columns: :rep_code, clustered: true)
            idx = Index.new(name: 'idx_reps_rep_code', table: :reps, columns: :rep_code, unique: true)
            expect(clustered_index.==(idx)).to be false
            expect(idx.==(clustered_index)).to be false
          end
        end
      end
    end
  end
end
