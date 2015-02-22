# Eithery Lab., 2015.
# Class Gauge::DB::Constraints::ForeignKeyConstraint specs.

require 'spec_helper'

module Gauge
  module DB
    module Constraints
      describe ForeignKeyConstraint do
        let(:dbo_name) { 'FK_TRADES_PRIMARY_REPS' }
        let(:dbo) { ForeignKeyConstraint.new(dbo_name, :trades, :rep_code, :primary_reps, :code) }
        subject { dbo }

        it_behaves_like "any composite database constraint"

        it { should respond_to :ref_table }
        it { should respond_to :ref_columns }


        describe '#ref_table' do
          it "equals to the table name passed in the initializer in various forms" do
            ConstraintSpecHelper.tables.each do |table_name, actual_table|
              foreign_key = ForeignKeyConstraint.new('fk_trades_primary_reps', :direct_trades, :rep_code, table_name, :code)
              foreign_key.ref_table.should == actual_table
            end
          end
        end


        describe '#ref_columns' do
          context "for regular foreign keys" do
            specify { subject.ref_columns.should include(:code) }
          end

          context "for composite foreign keys" do
            before do
              @composite_constraint = ForeignKeyConstraint.new('fk_trade_accounts', :trades,
                [:account_number, :source_firm_code], :accounts, [:number, 'Source'])
            end
            it "includes all data columns specified as a composite key in various forms" do
              @composite_constraint.ref_columns.count.should == 2
              @composite_constraint.ref_columns.should include(:number)
              @composite_constraint.ref_columns.should include(:source)
            end
          end
        end


        def constraint_for(*args)
          ForeignKeyConstraint.new(*args, :primary_reps, :code)
        end
      end
    end
  end
end
