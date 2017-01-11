# Eithery Lab, 2017
# Shared examples for database constraints specs.

require 'spec_helper'

module Gauge
  module DB
    module Constraints
      module SharedExamples
        include Constants, ConstraintSpecHelper

        shared_examples_for "any database constraint" do
        end


        shared_examples_for "any composite database constraint" do
          it_behaves_like "any database constraint"

          it { expect(dbo).to respond_to :columns }
          it { expect(dbo).to respond_to :composite? }


          describe '#columns' do
            context "when a constraint is applied to one column" do
              before { @constraint = constraint_for dbo_name, :primary_reps, :rep_code }
              it { expect(@constraint.columns).to include(:rep_code) }
            end

            context "when a constraint is applied to multiple columns" do
              before { @composite_constraint = constraint_for dbo_name, :trades, ['account_number', :source_firm_CODE]}

              it "includes all data columns specified in the constraint in various forms" do
                @composite_constraint.columns.count.should == 2
                @composite_constraint.columns.should include(:account_number)
                @composite_constraint.columns.should include(:source_firm_code)
              end
            end
          end


          describe '#composite?' do
            context "for regular (single column) database constraints" do
              it { should_not be_composite }
            end

            context "for composite (multiple column) database constraints" do
              before { @composite_constraint = constraint_for dbo_name, :trades, [:account_number, :source_firm_code] }
              specify { @composite_constraint.should be_composite }
            end
          end
        end

      end


      shared_examples_for "a data table constraint" do |options={}|
        it { expect(subject.name).to eq options[:name] }
        it { expect(subject.table).to eq options[:table] }

        if options.include? :columns
          it { expect(subject.columns).to have(options[:columns].count).columns }
          it { expect(subject.columns).to eq options[:columns] }
          it { is_expected.to be_composite }
        else
          it { expect(subject.columns).to have(1).column }
          it { expect(subject.columns).to include(options[:column]) }
          it { is_expected.not_to be_composite }
        end
      end


      shared_examples_for "a primary key" do |options={}|
        it { is_expected.to be_a PrimaryKeyConstraint }
        it_behaves_like "a data table constraint", options
      end


      shared_examples_for "an index" do |options={}|
        it { is_expected.to be_a Gauge::DB::Index }
        it_behaves_like "a data table constraint", options
      end


      shared_examples_for "a unique constraint" do |options={}|
        it { is_expected.to be_a UniqueConstraint }
        it_behaves_like "a data table constraint", options
      end


      shared_examples_for "a foreign key constraint" do |options={}|
        it { is_expected.to be_a ForeignKeyConstraint }
        it_behaves_like "a data table constraint", options
        it { expect(subject.ref_table).to eq options[:ref_table] }
        if options.include? :columns
          it { expect(subject.ref_columns).to have(options[:ref_columns].count).columns }
          it { expect(subject.ref_columns).to eq options[:ref_columns] }
        else
          it { expect(subject.ref_columns).to have(1).column }
          it { expect(subject.ref_columns).to include options[:ref_column] }
        end
      end
    end
  end
end
