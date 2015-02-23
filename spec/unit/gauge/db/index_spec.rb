# Eithery Lab., 2015.
# Class Gauge::DB::Index specs.

require 'spec_helper'

module Gauge
  module DB
    describe Index do
      let(:dbo_name) { "IDX_REP_CODE" }
      let(:dbo) { Index.new(dbo_name, :reps, :rep_code) }
      subject { dbo }

      it_behaves_like "any composite database constraint"

      it { should respond_to :clustered? }
      it { should respond_to :unique? }


      describe '#clustered?' do
        context "by default" do
          it { should_not be_clustered }
        end

        context "when specified as clustered" do
          before { @clustered_index = Index.new('idx_rep_code', :reps, :rep_code, clustered: true) }
          specify { @clustered_index.should be_clustered }
        end

        context "when specified as non clustered" do
          before { @nonclustered_index = Index.new('idx_rep_code', :reps, :rep_code, clustered: false) }
          specify { @nonclustered_index.should_not be_clustered }
        end

        context "when specified with incorrect value" do
          before { @nonclustered_index = Index.new('idx_rep_code', :reps, :rep_code, clustered: 'yes') }
          specify { @nonclustered_index.should_not be_clustered }
        end
      end


      describe '#unique' do
        context "by default" do
          it { should_not be_unique }
        end

        context "when specified as unique" do
          before { @unique_index = Index.new('idx_rep_code', :reps, :rep_code, unique: true) }
          specify { @unique_index.should be_unique }
        end

        context "when specified as not unique" do
          before { @nonunique_index = Index.new('idx_rep_code', :reps, :rep_code, unique: false) }
          specify { @nonunique_index.should_not be_unique }
        end

        context "when specified with incorrect value" do
          before { @nonunique_index = Index.new('idx_rep_code', :reps, :rep_code, unique: 'yes') }
          specify { @nonunique_index.should_not be_unique }
        end
      end
    end
  end
end
