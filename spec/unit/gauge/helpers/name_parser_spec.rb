# Eithery Lab, 2017
# Gauge::Helpers::NameParser specs

require 'spec_helper'

module Gauge
  module Helpers
    describe NameParser do
      subject { NameParser }

      it { should respond_to :local_name_of }
      it { should respond_to :sql_schema_of }
      it { should respond_to :dbo_key_of }


      describe '.local_name_of' do
        it "extracts the local part of a database object name" do
          (dbo_default_names + dbo_custom_names).each do |dbo_name|
            expect(NameParser.local_name_of(dbo_name.downcase)).to eq 'reps'
          end
        end
      end


      describe '.sql_schema_of' do
        context "for default SQL schema (dbo)" do
          it "returns 'dbo' as SQL schema" do
            dbo_default_names.each { |dbo_name| expect(NameParser.sql_schema_of(dbo_name.downcase)).to eq 'dbo' }
          end
        end

        context "for custom SQL schema" do
          it "extracts SQL schema part from a database object name" do
            dbo_custom_names.each { |dbo_name| expect(NameParser.sql_schema_of(dbo_name.downcase)).to eq 'bnr' }
          end
        end
      end


      describe '.dbo_key_of' do
        context "for default SQL schema (dbo)" do
          it "returns a database object name with 'dbo' SQL schema converted to symbol" do
            dbo_default_names.each { |dbo_name| expect(NameParser.dbo_key_of(dbo_name)).to be :dbo_reps }
          end
        end

        context "for custom SQL schema" do
          it "returns a database object name with custom SQL schema converted to symbol" do
            dbo_custom_names.each { |dbo_name| expect(NameParser.dbo_key_of(dbo_name)).to be :bnr_reps }
          end
        end
      end


  private

      def dbo_default_names
        ['REPS', 'dbo.reps', '"dbo"."reps"', '[dbo].[reps]', '[reps]', '[rep_profile].[dbo].[reps]', :reps,
          'rep_profile..reps', 'DBO.REPS', :DBO_reps, 'dbo_reps']
      end


      def dbo_custom_names
        ['BNR.RepS', '"bnr"."reps"', '[bnr].[reps]', '[rep_profile].[bnr].[reps]', 'rep_profile.bnr.reps']
      end
    end
  end
end
