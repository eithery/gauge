# Eithery Lab., 2015.
# Class Gauge::DB::Constraints::DefaultConstraint specs.

require 'spec_helper'

module Gauge
  module DB
    module Constraints
      UID = 'abs(convert(bigint,convert(varbinary,newid())))'

      describe DefaultConstraint do
        let(:dbo_name) { 'DF_REPS_IS_ACTIVE' }
        let(:dbo) { DefaultConstraint.new(dbo_name, :reps, :is_active, true) }
        subject { dbo }

        it_behaves_like "any database constraint"

        it { should respond_to :column }
        it { should respond_to :default_value }


        describe '#column' do
          it "equals to the column name passed in the initializer in various forms" do
            [:is_active, 'is_active', 'IS_ACTIVE'].each do |column_name|
              default_constraint = DefaultConstraint.new(dbo_name, :reps, column_name, true)
              default_constraint.column.should == :is_active
            end
          end
        end


        describe '#default_value' do
          subject { @default_constraint.default_value }

          context "for boolean columns" do
            before { @default_constraint = DefaultConstraint.new('df_reps_is_active', :reps, :is_active, true) }
            it { should be true }
          end

          context "for character columns" do
            before { @default_constraint = DefaultConstraint.new('df_address_country', :addresses, :country, 'US') }
            it { should == 'US' }
          end

          context "for expressions" do
            before { @default_constraint = DefaultConstraint.new('df_trade_id', :trades, :id, UID); }
            it { should == UID }
          end

          context "for SQL functions" do
            before do
              @default_constraint = DefaultConstraint.new('df_audit_trail_processed', :at_audit_trail,
                :processed, function: :getdate)
            end
            it { should == { function: :getdate } }
          end
        end


        def constraint_for(*args)
          DefaultConstraint.new(*args, 'R0001')
        end
      end
    end
  end
end
