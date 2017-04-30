# Eithery Lab, 2017
# Gauge::Helpers::NamesHelper specs

require 'spec_helper'

module Gauge
  module Helpers
    describe NamesHelper do
      class NamesHelperStub
        include NamesHelper
      end

      let(:helper) { NamesHelperStub.new }

      it { expect(helper).to respond_to :local_name_of, :sql_schema_of, :dbo_id }


      describe '#local_name_of' do
        it "extracts the local part of a database object name" do
          ALL_NAMES.each do |dbo_name|
            expect(helper.local_name_of(dbo_name.downcase)).to eq 'reps'
          end
        end

        it "does not change case of a database object name" do
          expect(helper.local_name_of('RepProfile')).to eq 'RepProfile'
          expect(helper.local_name_of(:RepProfile)).to eq 'RepProfile'
        end
      end


      describe '#sql_schema_of' do
        it "returns 'dbo' as a default SQL schema" do
          NAMES_WITH_DBO_SCHEMA.each do |dbo_name|
            expect(helper.sql_schema_of(dbo_name)).to eq 'dbo'
          end
        end

        it "extracts SQL schema part for a custom SQL schema" do
          NAMES_WITH_CUSTOM_SCHEMA.each do |dbo_name|
            expect(helper.sql_schema_of(dbo_name)).to eq 'bnr'
          end
        end

        it "converts SQL schema to lower case" do
          expect(helper.sql_schema_of('DBO.REPS')).to eq 'dbo'
          expect(helper.sql_schema_of(:DBO_REPS)).to eq 'dbo'
        end
      end


      describe '#dbo_id' do
        it "returns a database object name with 'dbo' SQL schema converted to a symbol" do
          NAMES_WITH_DBO_SCHEMA.each do |dbo_name|
            expect(helper.dbo_id(dbo_name)).to be :dbo_reps
          end
        end

        it "returns a database object name with custom SQL schema converted to a symbol" do
          NAMES_WITH_CUSTOM_SCHEMA.each do |dbo_name|
            expect(helper.dbo_id(dbo_name)).to be :bnr_reps
          end
        end
      end


  private

      NAMES_WITH_DBO_SCHEMA = ['REPS', 'dbo.reps', '"dbo"."reps"', '[dbo].[reps]', '[reps]',
        '[rep_profile].[dbo].[reps]', :reps, 'rep_profile..reps', 'DBO.REPS', :DBO_reps, 'dbo_reps']

      NAMES_WITH_CUSTOM_SCHEMA = ['BNR.RepS', '"bnr"."reps"', '[bnr].[reps]', '[rep_profile].[bnr].[reps]',
        'rep_profile.bnr.reps']

      ALL_NAMES = NAMES_WITH_DBO_SCHEMA + NAMES_WITH_CUSTOM_SCHEMA
    end
  end
end
