# Eithery Lab., 2015.
# Class Gauge::DB::Constraints::PrimaryKeyConstraint specs.

require 'spec_helper'

module Gauge
  module DB
    module Constraints
      describe PrimaryKeyConstraint do
        let(:dbo_name) { 'PK_Primary_Reps' }
        let(:dbo) { PrimaryKeyConstraint.new(dbo_name, :reps, :rep_code) }
        subject { dbo }

        it_behaves_like "any composite database constraint"

        it { should respond_to :clustered?, :composite? }


        describe '#clustered?' do
          context "by default" do
            it { should be_clustered }
          end

          context "when specified as nonclustered" do
            before { @nonclustered_key = PrimaryKeyConstraint.new('pk_reps', :reps, :id, clustered: false) }
            specify { @nonclustered_key.should_not be_clustered }
          end

          context "when specified as clustered" do
            before { @clustered_key = PrimaryKeyConstraint.new('pk_reps', :reps, :id, clustered: true) }
            specify { @clustered_key.should be_clustered }
          end

          context "when specified with incorrect value" do
            before { @clustered_key = PrimaryKeyConstraint.new('pk_reps', :reps, :id, clustered: 'no') }
            specify { @clustered_key.should be_clustered }
          end
        end


        describe '#composite?' do
          context "for regular primary keys" do
            it { should_not be_composite }
          end

          context "for composite primary keys" do
            before do
              @composite_constraint = PrimaryKeyConstraint.new('pk_direct_trades', :trades, [:account_number, :source_firm_code])
            end
            specify { @composite_constraint.should be_composite }
          end
        end
      end
    end
  end
end
